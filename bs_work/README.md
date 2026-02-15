# bs_work

## Overview

A serial Raymond workflow that claims tasks from a beads server (`bs`),
implements them, reviews the work, and commits. After each task is
completed and pushed, the workflow loops back to claim the next one,
continuing until no tasks remain.

## Workflow

```
1_START
    |
    v
  any in-progress? (bs mine)
    |          \
   yes          no
    |            \
    v             v
  show it     any ready? (bs list --ready)
    |            |          \
    |           yes          no
    |            |            \
    |         claim it      <result>DONE</result>
    |            |
    |          show it
    |            |
    v            v
       2_IMPL
          |
          v
       3_CHECK_FIX  <─────────────────┐
          |                            |
          v                            |
       4_NO_FIX                        |
          |        \                   |
       nothing    something            |
       fixed       fixed               |
          |           \                |
          v            └───────────────┘
       5_COMMIT
          |        \
       successful  unsuccessful
          |            \
          |          <result>INCOMPLETE</result>
          v
       commit, push
       bs close <id>
          |
          v
       more tasks? (bs list --ready)
          |           \
         yes           no
          |             \
       <reset>        <result>SUCCESS</result>
       1_START
```

## States

### 1_START.md

Entry point. Checks for in-progress work from a previous run (`bs mine`).
If none, checks for ready tasks (`bs list --ready`). If a task is
available, claims it (`bs claim <id>`) and retrieves its description
(`bs show <id>`). If no tasks are available, terminates with
`<result>DONE</result>`.

Does not begin implementation — stops after retrieving the task
description and transitions to 2_IMPL.

### 2_IMPL.md

Implements the task based on its description. The bs item is kept
in-progress (not closed) because evaluation and commit must happen first.

Has a single implicit transition to 3_CHECK_FIX.

### 3_CHECK_FIX.md

Self-review step. The agent reviews all work done so far, looking for
mistakes, errors, or opportunities for improvement. There may be nothing
wrong — the point is to check.

Has a single implicit transition to 4_NO_FIX.

### 4_NO_FIX.md

Decision point after the review. Examines whether the previous review
actually fixed anything or if everything was already correct.

- If something was fixed (major or minor): loops back to 3_CHECK_FIX
  for another review pass.
- If nothing was fixed (everything is good): proceeds to 5_COMMIT.

Observations marked "not a bug" count as nothing fixed.

### 5_COMMIT.md

Final evaluation and commit step. Examines the conversation history to
determine if the task was successfully completed.

**If unsuccessful or incomplete** (features missing, tests failing, etc.):
- Leaves the bs item in-progress.
- Leaves files dirty (no staging or commit).
- Terminates with `<result>INCOMPLETE</result>`.

**If successful:**
- Stages and commits the changes (`git add`, `git commit`).
- Pushes to the remote.
- Closes the bs item (`bs close <id>`).
- Checks for more ready tasks (`bs list --ready`).
  - If more tasks exist: resets to 1_START (`<reset>1_START</reset>`)
    with a fresh context for the next task.
  - If no more tasks: terminates with `<result>SUCCESS</result>`.

## Commit Conventions

- Do not mention Claude Code as a coauthor or contributor.
- Add "Built with Raymond (Agent Orchestrator)" at the end of the
  commit message.

## Terminal States

| Result | Meaning |
|--------|---------|
| `DONE` | No tasks were available to work on. |
| `INCOMPLETE` | A task was claimed but could not be completed successfully. |
| `SUCCESS` | All available tasks have been completed. |

## Review Loop

The 3_CHECK_FIX / 4_NO_FIX cycle forms an iterative review loop. Each
pass through CHECK_FIX reviews the current state of the work. If any
fixes are applied, NO_FIX sends it back for another review. The loop
exits only when a review pass finds nothing to fix, ensuring the work
is clean before committing.

## Context Management

- States 1_START through 4_NO_FIX use `<goto>` transitions, preserving
  the Claude Code session context throughout implementation and review.
  This means the commit step can see the full history of what was
  implemented and reviewed.
- The transition back to 1_START after completing a task uses `<reset>`,
  discarding the previous task's context and starting a fresh session
  for the next task.

## Comparison with bs_work_multi

`bs_work` is the simpler, serial variant. It processes one task at a
time in a single directory. `bs_work_multi` extends this design to run
multiple instances in parallel, each in its own checkout, adding a
rebase-and-push loop and bail-out logic to handle concurrent pushes.
