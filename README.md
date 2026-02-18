# Raymond Workflow Samples

Sample workflows for [Raymond](https://github.com/anthropics/raymond), an agent orchestrator that automates AI coding agents like Claude Code.

Raymond treats workflows as state machines where each state is a markdown prompt (`.md`) or a shell script (`.sh`). States declare their own transitions using XML tags (`<goto>`, `<reset>`, `<call>`, `<result>`, etc.), and Raymond's orchestrator interprets these tags to drive the workflow forward.

## Workflows

Each workflow has its own README with full state descriptions, context management details, and design notes. The pseudocode below shows the high-level flow.

### [bs_work](bs_work/) — Beads Server Work Loop

Claims tasks from a [beads server](https://github.com/vector76/beads_server), implements them one at a time with a self-review loop, and commits. Loops until the backlog is empty.

```
START: check for in-progress work, or claim a ready task
  if no tasks → result DONE
IMPL: implement the task
CHECK_FIX: self-review the work
NO_FIX: did the review fix anything?
  if yes → goto CHECK_FIX
COMMIT: commit, push, close the task
  if more tasks → reset to START
  else → result SUCCESS
```

### [bs_work_multi](bs_work_multi/) — Parallel Beads Server Work Loop

A variant of `bs_work` designed for multiple independent Raymond instances running in parallel, each in its own checkout. Instances coordinate only at `git push` time via a rebase loop with conflict resolution, re-testing, and a retry cap.

```
START: initial setup
CLAIM_TASK: claim a ready task from beads server
  if nothing ready → CHECK_DONE (poll loop)
IMPLEMENT: implement the task
CHECK_FIX: self-review the work
NO_FIX: did the review fix anything?
  if yes → goto CHECK_FIX
COMMIT: commit locally
  if unsuccessful → BAIL_OUT
PUSH_GATE: check retry counter
  if over cap → BAIL_OUT
  call FETCH_REBASE (isolated session):
    rebase onto origin/main
    if conflicts → RESOLVE_CONFLICTS
    if rebased → RE_TEST
    returns ok, REWORK, or BAIL
PUSH: inspect call result
  if ok → try git push
    if rejected → goto PUSH_GATE (retry)
    if success → CLOSE_TASK → reset to CLAIM_TASK
  if REWORK → RUN_TESTS → CHECK_FIX (re-enter review loop)
  if BAIL → BAIL_OUT
BAIL_OUT: discard work, unclaim task → reset to CLAIM_TASK
CHECK_DONE: poll for ready/open tasks
  if ready found → reset to CLAIM_TASK
  if open tasks exist → sleep, poll again
  if nothing open → result DONE
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

A human-in-the-loop workflow that collaboratively elaborates a feature document. Starting from a brief description — as short as a single sentence — the agent analyzes the codebase, identifies gaps and ambiguities, makes concrete assumptions, and proposes them for human review. The human approves, overrides, or adds information, and the loop continues until the document is complete and well-specified.

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

### [feat_plan](feat_plan/) — Feature Document to Implementation Plan

Takes a feature document and produces a detailed, high-level implementation plan. Researches the relevant parts of the codebase to ground the plan in the existing architecture, then iteratively reviews and refines it until no further improvements are found. The plan focuses on strategy, sequencing, and dependencies — not code.

```
START: read feature document from --input file, derive plan filename ([feature]_plan.md)
  if no input → result error
DRAFT_PLAN: re-read feature doc, research relevant codebase, write plan file
REVIEW_FIX: re-read plan with fresh eyes, fix missing steps / dependency
            violations / coverage gaps / over- or under-specification
CHECK_CONVERGENCE: did the review fix anything?
  if yes → goto REVIEW_FIX
  if no → result [feature]_plan.md
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

### [human_prd](human_prd/) — Interactive PRD Refinement

An interactive loop where the agent drafts a PRD (`PRD.md`) and pauses for human input via `HUMAN_PROMPT.md`. The human removes a `<!-- COMPOSING -->` marker to signal their response is ready.

```
START: read PRD.md (if exists), write questions to HUMAN_PROMPT.md
PROMPT: wait for human to remove <!-- COMPOSING --> marker
  if human wrote a response → continue
  if human left file empty → CLEANUP → result DONE
RESPONSE: read human input, refine PRD.md
  → reset to START
```

## Raymond Concepts Used

These samples exercise several key Raymond features:

| Feature | Description | Used In |
|---------|-------------|---------|
| `<goto>` | Continue in the same context (session preserved) | All workflows |
| `<reset>` | Discard context and start fresh | `bs_work`, `bs_work_multi`, `taskmd_work`, `human_prd` |
| `<result>` | Return a value / terminate the agent | All workflows |
| `<call>` | Invoke a sub-workflow and return the result | `taskmd_work` (review loop), `bs_work_multi` (rebase loop) |
| `<call return="...">` | Specify a return destination for the call result | `taskmd_work`, `bs_work_multi` |
| Shell script states (`.sh`) | Zero-cost deterministic control flow | `taskmd_work`, `bs_work_multi`, `feat_develop`, `human_prd` |
| YAML frontmatter | Declare allowed transitions and model selection | All `.md` states |
| `model: sonnet` | Use a cheaper model for simple evaluation steps | `taskmd_work` |
| `effort: low` | Use extended thinking at low effort for fast decisions | `plan_to_beads`, `feat_plan` |
| `{{result}}` / `RAYMOND_RESULT` | Template variable for receiving return values | `taskmd_work`, `bs_work_multi`, `feat_develop`, `feat_plan`, `plan_to_beads` |

## Running a Workflow

```bash
# Start a workflow by pointing Raymond at the first state file
raymond bs_work/1_START.md
raymond bs_work_multi/1_START.md
raymond taskmd_work/1_START.md
raymond feat_develop/1_START.md --input "my_feature.md"
raymond feat_plan/1_START.md --input "my_feature.md"
raymond plan_to_beads/1_START.md --input "my_plan.md"
raymond human_prd/1_START.md

# With options
raymond taskmd_work/1_START.md --model sonnet --budget 5.00
raymond bs_work/1_START.md --dangerously-skip-permissions
```

## Prerequisites

- [Raymond](https://github.com/anthropics/raymond) installed and on your PATH
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed (Raymond invokes it under the hood)
- For `bs_work` / `bs_work_multi`: the `bs` CLI from [Beads Server](https://github.com/vector76/beads_server) installed and configured
- For `bs_work_multi`: separate directory with its own git clone (or worktree) per instance
- For `taskmd_work`: one or more `TASK.md` / `TASK1.md` / `TASK2.md` files in the working directory
- For `feat_develop`: a feature document file to pass via `--input`; `inotifywait` available (from `inotify-tools` on Linux) for human-input polling
- For `feat_plan`: a feature document file to pass via `--input`
- For `plan_to_beads`: an implementation plan file to pass via `--input`
- For `human_prd`: `inotifywait` available (from `inotify-tools` on Linux)
