# Raymond Workflow Samples

Sample workflows for [Raymond](https://github.com/anthropics/raymond), an agent orchestrator that automates AI coding agents like Claude Code.

Raymond treats workflows as state machines where each state is a markdown prompt (`.md`) or a shell script (`.sh`). States declare their own transitions using XML tags (`<goto>`, `<reset>`, `<call>`, `<result>`, etc.), and Raymond's orchestrator interprets these tags to drive the workflow forward.

## Workflows

Each workflow has its own README with full state descriptions, context management details, and design notes. The pseudocode below shows the high-level flow.

### [bs_work](bs_work/) — Beads Server Work Loop

Claims tasks from a [beads server](https://github.com/vector76/beads_server), implements them one at a time with a self-review loop, then commits and pushes. Loops until the backlog is empty. Also supports a `RUN_FOREVER` entry point that never terminates on its own — it resets back to the top after each task or error.

```
START: check bs configuration
CLAIM: check for in-progress task, or claim a ready one
  if no tasks → result DONE
WORK: implement the task
REVIEW: self-review with fresh eyes
  call DID_FIX → AGAIN_CHOICE:
    if fixed → goto REVIEW
COMMIT: stage, commit, push; mark task complete
  if problem → result PROBLEM
DONE: if GOOD → reset to CLAIM
      else → result
```

### [bs_work_rebase](bs_work_rebase/) — Beads Server Work Loop with Rebase

A single-agent variant of `bs_work` that handles push rejection with a rebase loop. When `git push` is rejected, the agent fetches, rebases, resolves conflicts (if any), re-tests, and retries. Bail-out logic unclaimss the task after too many failed attempts.

```
START: check bs configuration
CLAIM: check for in-progress task, or claim a ready one
  if no tasks → result DONE
WORK: implement the task
REVIEW: self-review with fresh eyes
  call DID_FIX → AGAIN_CHOICE:
    if fixed → goto REVIEW
COMMIT: stage and commit locally (no push)
PUSH_ATTEMPT: try git push
  if success → mark complete; result GOOD
  if rejected → REBASE
REBASE: git fetch + rebase
  if clean → RETEST
  if conflicts → RESOLVE
RESOLVE: LLM resolves conflicts (3-attempt cap)
  if resolved → RETEST
  if unresolvable → BAIL_OUT
RETEST: run tests
  if pass → PUSH_ATTEMPT
  if fail → REWORK
REWORK: fix test failures (3-attempt cap)
  if fixed → COMMIT
  if stuck → BAIL_OUT
BAIL_OUT: hard reset, unclaim task; result BAIL_OUT
DONE: if GOOD or BAIL_OUT → reset to CLAIM
      else → result
```

### [taskmd_work](taskmd_work/) — TASK.md File Work Loop

Reads numbered `TASK<n>.md` files from the working directory, implements them one at a time with a self-review loop, and commits. Uses shell scripts for zero-cost control flow and `<call>` to isolate review context.

```
START: find lowest TASK<n>.md, implement it
CHECK_WRAP: call CHECK_FIX (isolated session):
  CHECK_FIX: self-review the work
  NO_FIX: did the review fix anything?
    if yes → result SOMETHING FIXED
    if no → result DONE
CHECK_DONE: inspect call result
  if SOMETHING FIXED → goto CHECK_WRAP
  if DONE → continue
COMMIT: rename task file, commit, push
  if unsuccessful → result INCOMPLETE
  if more tasks → reset to START
  else → result SUCCESS
```

### [feat_develop](feat_develop/) — Interactive Feature Document Elaboration

A human-in-the-loop workflow that collaboratively elaborates a feature document. Starting from a brief description, the agent analyzes the codebase, identifies gaps and ambiguities, makes concrete assumptions, and proposes them for human review via a file-based prompt (`HUMAN_PROMPT.md`). The human removes a `<!-- COMPOSING -->` marker to signal their response is ready. Loops until the document is complete.

```
START: read feature document from --input file
  if no input → result error
ANALYZE: re-read feature doc, explore codebase, identify gaps/ambiguities,
         write assumptions and issues to HUMAN_PROMPT.md
PROMPT: (shell) wait for human to remove <!-- COMPOSING --> marker
  if human responded → continue
  if human left file empty → CLEANUP → result DONE
RESPONSE: apply human feedback, update feature document in place
  → goto ANALYZE (loop)
```

### [feat_dev_tg](feat_dev_tg/) — Interactive Feature Document Elaboration via Telegram

A variant of `feat_develop` that uses `tgask` to send and receive human input over Telegram instead of polling a file. Automatically picks up `underspec_<name>.md` files, refines them collaboratively, and renames the completed document to `fullspec_<name>.md`. Loops back to find the next underspec file when done.

```
START: find an underspec_<name>.md with no in_progress_ or fullspec_ counterpart
  if none found → result DONE
  copy to in_progress_<name>.md; call ANALYZE
ANALYZE: expand document, write questions to HUMAN_PROMPT.md
PROMPT: (shell) run tgask to send prompt and receive response
  if response is "done" only → CLEANUP
  if last line is "done" → FINAL_RESPONSE
  else → RESPONSE
RESPONSE: update in_progress file from human response → goto PROMPT (loop)
FINAL_RESPONSE: apply final response, → CLEANUP
CLEANUP: rename in_progress_ → fullspec_, delete underspec_; result DONE
DONE: (shell) reset to START
```

### [feat_to_beads](feat_to_beads/) — Feature Document to Beads

Takes a feature specification document and produces a set of implementation beads. Runs in two phases separated by a context reset: Phase 1 drafts and refines an implementation plan; Phase 2 explores codebase integration points, generates a bead list, refines it, then creates all beads with dependencies.

```
START: validate --input file; abort if plan.md or bead_list.md already exist
DRAFT_PLAN: read feature doc, explore codebase, write plan.md
REVIEW_PLAN: review and fix plan.md
CHECK_PLAN: did the review fix anything?
  if yes → goto REVIEW_PLAN
  if no → [context reset]
EXPLORE_CODEBASE: read plan.md, explore integration points
GENERATE_BEADS_LIST: write bead_list.md
REVIEW_BEADS: review and fix bead_list.md
CHECK_BEADS: did the review fix anything?
  if yes → goto REVIEW_BEADS
CREATE_BEADS: create all beads, set up dependencies
VALIDATE: verify all beads created correctly
  → result SUCCESS or VALIDATION FAILED
```

### [plan_to_beads](plan_to_beads/) — Plan to Beads Conversion

Transforms an implementation plan into structured beads on a beads server. Generates a bead list, iteratively reviews it until converged, then creates all beads with dependencies.

```
START: read implementation plan from --input file
  if no input specified → result error
GENERATE_BEADS_LIST: create bead_list.md from plan
REVIEW_FIX: review bead_list.md for issues, fix them
CHECK_CONVERGENCE: did the review fix anything?
  if yes → goto REVIEW_FIX
CREATE_BEADS: create all beads via bs, set up dependencies
VALIDATE: verify all beads and dependencies were created
  → result SUCCESS or VALIDATION FAILED
```

### [fullspec_to_beads](fullspec_to_beads/) — Fullspec Document to Beads

Similar to `feat_to_beads` but auto-detects `fullspec_<name>.md` files in the filesystem (the output format of `feat_dev_tg`) rather than taking an `--input` argument. Writes `plan_<name>.md` and `beads_<name>.md` alongside the source file. Loops back to find the next eligible fullspec when done.

```
START: find a fullspec_<name>.md with no plan_ or beads_ counterpart
  if none → result DONE
  call DRAFT_PLAN (with fullspec file as input)
DRAFT_PLAN: read fullspec, explore codebase, write plan_<name>.md
REVIEW_PLAN: review and fix plan
  call PLAN_DID_FIX → PLAN_AGAIN_CHOICE:
    if fixed → goto REVIEW_PLAN
TRANSITION: reset context; goto EXPLORE_CODEBASE with plan file as input
EXPLORE_CODEBASE: read plan, explore integration points; write beads_<name>.md
REVIEW_BEADS: review and fix bead list
  call BEADS_DID_FIX → BEADS_AGAIN_CHOICE:
    if fixed → goto REVIEW_BEADS
CREATE_BEADS: create all beads, set up dependencies
VALIDATE: verify beads → result SUCCESS or VALIDATION FAILED
DONE: (shell) reset to START
```

## Raymond Concepts Used

These samples exercise several key Raymond features:

| Feature | Description | Used In |
|---------|-------------|---------|
| `<goto>` | Continue in the same context (session preserved) | All workflows |
| `<reset>` | Discard context and start fresh | `bs_work`, `bs_work_rebase`, `taskmd_work`, `feat_dev_tg`, `fullspec_to_beads` |
| `<result>` | Return a value / terminate the agent | All workflows |
| `<call>` | Invoke a sub-workflow and return the result | `taskmd_work`, `bs_work`, `bs_work_rebase`, `feat_to_beads`, `fullspec_to_beads` |
| `<call return="...">` | Specify a return destination for the call result | `bs_work`, `bs_work_rebase`, `taskmd_work`, `feat_to_beads`, `fullspec_to_beads` |
| `<function>` | Call a sub-workflow like a function call with input | `bs_work`, `bs_work_rebase`, `feat_dev_tg`, `fullspec_to_beads` |
| Shell script states (`.sh`) | Zero-cost deterministic control flow | All workflows |
| YAML frontmatter | Declare allowed transitions and model selection | All `.md` states |
| `model: sonnet` | Use a cheaper model for simple evaluation steps | `taskmd_work` |
| `effort: low` | Use extended thinking at low effort for fast decisions | `feat_to_beads`, `plan_to_beads` |
| `{{result}}` / `RAYMOND_RESULT` | Template variable for receiving return values | `bs_work`, `bs_work_rebase`, `taskmd_work`, `feat_dev_tg`, `feat_to_beads`, `fullspec_to_beads`, `plan_to_beads` |

## Running a Workflow

```bash
# Beads workflows
raymond bs_work/START.sh
raymond bs_work/RUN_FOREVER.sh          # never-terminating variant
raymond bs_work_rebase/START.sh

# Task file workflow
raymond taskmd_work/1_START.md

# Feature elaboration (file-based human prompts)
raymond feat_develop/1_START.md --input "my_feature.md"

# Feature elaboration (Telegram-based human prompts)
raymond feat_dev_tg/START.sh

# Feature to beads (single workflow)
raymond feat_to_beads/1_START.md --input "my_feature.md"

# Plan to beads
raymond plan_to_beads/1_START.md --input "my_plan.md"

# Fullspec to beads (auto-detects fullspec_*.md files)
raymond fullspec_to_beads/START.sh

# With options
raymond taskmd_work/1_START.md --model sonnet --budget 5.00
raymond bs_work_rebase/START.sh --dangerously-skip-permissions
```

## Prerequisites

- [Raymond](https://github.com/anthropics/raymond) installed and on your PATH
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed (Raymond invokes it under the hood)
- For `bs_work` / `bs_work_rebase`: the `bs` CLI from [Beads Server](https://github.com/vector76/beads_server) installed and configured
- For `taskmd_work`: one or more `TASK.md` / `TASK1.md` / `TASK2.md` files in the working directory
- For `feat_develop`: a feature document file to pass via `--input`; `inotifywait` available (from `inotify-tools` on Linux) for human-input polling
- For `feat_dev_tg`: `tgask` installed and configured for Telegram interaction; `underspec_<name>.md` files in the working directory
- For `feat_to_beads`: a feature document file to pass via `--input`; `bs` CLI configured
- For `plan_to_beads`: an implementation plan file to pass via `--input`; `bs` CLI configured
- For `fullspec_to_beads`: `fullspec_<name>.md` files in the working directory (e.g. produced by `feat_dev_tg`); `bs` CLI configured
