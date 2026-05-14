# Workflow Samples

A small collection of [Raymond](https://github.com/vector76/raymond) workflows
for running Claude as a planner and/or implementer against a beads-style task
queue (plus a minimal `ray serve` smoke test).

Each workflow is a single-file YAML state machine. States are either shell
scripts (`sh:`) or Claude prompts (`prompt:`); transitions are emitted as XML
tags like `<goto>`, `<fork>`, `<call>`, `<reset>`, and `<result>`.

## Workflows at a glance

| Workflow | One-line summary |
|---|---|
| [`check_prereqs.yaml`](#check_prereqsyaml--prerequisite-check) | Verify required tools and Claude settings are present before running anything else. |
| [`work.yaml`](#workyaml--bead-implementer-bm) | Long-running worker that claims, implements, reviews, and pushes beads (targets `bm`). |
| [`work_bs.yaml`](#work_bsyaml--bead-implementer-bs) | Same implementer loop as `work.yaml`, targeting a bare `bs` beads server. |
| [`agent.yaml`](#agentyaml--feature-planner-bm) | Long-running feature planner: dialogs, plans, and generates beads via `bm`. |
| [`feature_dialog.yaml`](#feature_dialogyaml--feature-refinement-dialog) | Standalone `<ask>`-driven dialog that refines a feature description (the dialog half of `agent.yaml`). |
| [`bead_creation.yaml`](#bead_creationyaml--feature-document-to-beads-bs) | Standalone pipeline turning a finished `feature.md` into beads on `bs` (the generate half of `agent.yaml`). |
| [`work_and_agent.yaml`](#work_and_agentyaml--run-both) | Launcher that forks `agent.yaml` and `work.yaml` as concurrent children. |
| [`story_input.yaml`](#story_inputyaml--serve-smoke-test) | Minimal two-state workflow exercising `ray serve` launch input and one `<ask>` round-trip. |

## Backing tools

The workflows shell out to one of two CLIs, which expose essentially the same
bead API (`add`, `claim`, `list`, `show`, `edit`, `close`, `mine`,
`wait-ready`, …):

- **`bm`** — backlog manager. Adds a feature-orchestration layer on top of
  beads (`claim-feature`, `fetch`, `start-generate`, `register-bead`,
  `beads-done`, `submit`, `register-artifact`, …). Required by `agent.yaml`.
- **`bs`** — beads server. The bare bead store; no feature layer.

`work.yaml` and `work_bs.yaml` are the same workflow targeting `bm` and `bs`
respectively. `agent.yaml` only works against `bm` because it depends on the
feature commands.

## The workflows

### `check_prereqs.yaml` — prerequisite check

A single-state shell workflow that fails fast if the environment isn't set
up. It takes no input and just runs, emitting `<result>OK</result>` when
every check passes or `<result>MISSING: …</result>` (with the reason) on the
first failure. Current checks:

1. `bs` is on `PATH`.
2. `bs list` returns valid JSON — i.e. the beads server is reachable and auth
   is configured (the exit code is unreliable, so the JSON parse is the real
   signal).
3. `jq` is on `PATH`.
4. `~/.claude/settings.json` exists and has `attribution.commit` and
   `attribution.pr` set to `""`, and `includeCoAuthoredBy` set to `false`.
5. `clusage-cli` is on `PATH` and `clusage-cli ping` returns `OK`.
6. `settings.json` wires a `Stop` hook running `clusage-cli log --from-hook`.

Each check is an independent block; extend it by appending another in the
same `… || fail "reason"` style.

### `work.yaml` — bead implementer (bm)

A long-running worker that pulls ready beads off the queue, implements them,
and pushes the result. The main loop:

1. **START / ONCE** — wait for `bm` to be ready, confirm the project is
   configured.
2. **CLAIM** — pick up an in-progress bead left over from a previous run
   (`bm mine`), or claim a new ready bead (`bm list --ready` + `bm claim`).
   If nothing is ready, exit cleanly.
3. **WORK** — Claude reads the bead via `bm show` and implements it.
4. **REVIEW → DID_FIX → AGAIN_CHOICE** — review pass with fresh eyes; loop
   until a review finds nothing to fix.
5. **COMMIT** — Claude decides whether the work is actually done. If yes,
   stage and commit (no push yet). If no, `BAIL_OUT`.
6. **PUSH_ATTEMPT** — `git push` with a retry counter (max 5). On rejection,
   go to **REBASE**; on success, go to **CLOSE_TASK**.
7. **REBASE → RESOLVE / RETEST → REWORK** — fetch, rebase onto the remote
   head, resolve conflicts if any, re-run tests, and loop back to either
   `PUSH_ATTEMPT` or `COMMIT` depending on what changed.
8. **CLOSE_TASK** — `bm close <id>`.
9. **DONE** — loop back to `CLAIM` for the next bead.

**BAIL_OUT** is the safety valve: `git rebase --abort`, hard-reset the branch
to `origin/<branch>`, `git clean -fd`, drop the assignee and reopen the bead
so another worker can pick it up.

### `work_bs.yaml` — bead implementer (bs)

Mechanically identical to `work.yaml`, but every `bm` command is swapped for
`bs`. Use this when your queue is just a beads server with no feature layer
in front of it.

### `agent.yaml` — feature planner (bm)

A long-running worker on the **feature** side of `bm`. It blocks on
`bm claim-feature`, which atomically hands out either a dialog step or a
generation task, then forks a child to handle it while the main thread
loops back for more work. Stops cleanly if a `STOP_REQUESTED` file appears
at the workflow root.

Each claim dispatches into one of three sub-flows:

- **Dialog** (`DIALOG_FIRST` / `DIALOG_NEXT` / `DIALOG_LAST` /
  `DIALOG_FINALIZE`). Claude reads the feature description, raises
  assumptions and ambiguities, and writes them back. The human responds out
  of band; subsequent dialog rounds incorporate the response. Per-feature
  scratch lives under `.bm/<agent-id>/`. The final state submits the
  refined feature back to `bm`.

- **Generate plan → beads** (`GENERATE` →
  `GENERATE_DRAFT_PLAN` → `REVIEW_PLAN` → `PLAN_DID_FIX` /
  `PLAN_AGAIN_CHOICE` → `EXPLORE_CODEBASE` → `REVIEW_BEADS` →
  `BEADS_DID_FIX` / `BEADS_AGAIN_CHOICE` → `CREATE_BEADS` → `VALIDATE`).
  Claude writes a strategic, implementation-free plan; reviews and revises
  until converged; explores the codebase; produces a list of independently
  executable beads (45 min – 1.5 hr each); reviews and revises that list;
  creates the beads via `bm add` with `--status not_ready`; wires up
  dependencies with `bm link`; flips them to `open`; registers them against
  the feature; and validates the result. The `DID_FIX` gates use Haiku to
  keep the converge-or-loop check cheap.

- **Generate direct-to-bead** (`GENERATE_DIRECT` → `GENERATE_DIRECT_2`).
  Short path for features small enough to be a single bead — skip the plan
  and beads-list ceremony, just create one bead with the feature document
  as its description.

`CLEANUP` removes the per-feature scratch directory and the forked worker
terminates; the main thread keeps claiming.

### `feature_dialog.yaml` — feature refinement dialog

The dialog half of `agent.yaml` pulled out standalone — no `bm`, no claim
loop, no fork. The human types the feature description into the first
`<ask>`, then iterates with the assistant: each round the assistant analyzes
the current `feature.md`, folds in corrections and assumptions, and asks any
remaining questions via `<ask>`. Replying `done` locks the document;
`FINALIZE` then asks whether to hand off to `bead_creation.yaml` — yes
triggers a `<reset-workflow>`, no terminates with the `feature.md` path as
the result. One-shot per `ray` invocation; scratch lives under
`{{task_folder}}`.

### `bead_creation.yaml` — feature document to beads (bs)

The generate half of `agent.yaml` pulled out standalone, targeting `bs`
(no feature layer, so no `bm register-*` / `beads-done` calls). Takes a path
to a finished `feature.md` as `{{input}}`, then runs the
plan → review → explore-codebase → review → create pipeline:
`GENERATE_DRAFT_PLAN` → `REVIEW_PLAN` → `EXPLORE_CODEBASE` →
`REVIEW_BEADS` → `CREATE_BEADS` → `VALIDATE`. Runs end-to-end without human
intervention. Two entry routes: as the `<reset-workflow>` handoff target
from `feature_dialog.yaml`, or standalone via
`ray run bead_creation.yaml --input /path/to/feature.md`.

### `work_and_agent.yaml` — run both

Three-state launcher that forks `agent.yaml` and `work.yaml` as concurrent
child workflows so one Raymond instance acts as both planner and
implementer. `work.yaml` already waits for `bm` to be ready in its own
START state, so this file doesn't reimplement that gating.

### `story_input.yaml` — serve smoke test

A minimal two-state workflow with no beads involvement — its real job is to
exercise the `ray serve` launch path: a required launch input plus one
`<ask>` round-trip with the human.

1. **START** — Claude writes a one-paragraph story about the launch
   `Subject` and emits it inside `<ask next="REVIEW">`, so the story itself
   becomes the prompt the human responds to.
2. **REVIEW** — folds the human's feedback in, writes the updated story to
   `story.md`, and emits `<result>SUCCESS</result>`.

Start the daemon with `ray serve --root . --port 5173` and launch it from
the web UI — the quickest way to confirm serve, launch input, and `<ask>`
delivery all work end to end.

## Running

```bash
ray run check_prereqs.yaml     # environment sanity check
ray run agent.yaml             # planner only
ray run work.yaml              # implementer only (bm)
ray run work_bs.yaml           # implementer only (bs)
ray run work_and_agent.yaml    # both

ray run feature_dialog.yaml                          # refine a feature interactively
ray run bead_creation.yaml --input path/to/feature.md  # feature doc -> beads (bs)

ray serve --root . --port 5173   # serve all workflows; story_input.yaml is the launch/input smoke test
```

Both long-running workflows are idempotent across restarts — `work.yaml`
picks up any in-progress bead assigned to the current user via `bm mine`,
and `agent.yaml` blocks on `bm claim-feature` which is exclusive per agent.
