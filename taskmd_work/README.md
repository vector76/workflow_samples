# taskmd_work

## Overview

A Raymond workflow that processes tasks defined as markdown files
(`TASK.md`, `TASK1.md`, `TASK2.md`, etc.) in the working directory.
It picks up the lowest-numbered task, implements it, runs an iterative
review loop, then commits and moves on to the next task until all tasks
are complete.

Unlike `bs_work`, which uses a beads server for task management, this
workflow uses the filesystem: each task is a markdown file and
completion is signaled by renaming it to `TASK-DONE-[datetime].md`.

## Workflow

```
1_START
    |
    v
  find lowest TASK<n>.md
  read & implement
    |
    v
2_CHECK_WRAP.sh ·········  $0 script
    |
    |  <call return="5_CHECK_DONE">3_CHECK_FIX.md</call>
    |
    |   call branch (isolated session)
    |   ·····························
    |   :                           :
    |   :  3_CHECK_FIX              :
    |   :      |                    :
    |   :      v                    :
    |   :  4_NO_FIX (sonnet)        :
    |   :      |          \         :
    |   :   something    nothing    :
    |   :    fixed        fixed     :
    |   :      |            \       :
    |   :      v             v      :
    |   :  <result>       <result>  :
    |   :  SOMETHING      DONE     :
    |   :  FIXED</result> </result> :
    |   ·····························
    |
    v
5_CHECK_DONE.sh ·········  $0 script: route on result
    |           \
    |        "SOMETHING FIXED"
    |         or empty
    |              \
    |            2_CHECK_WRAP.sh
    |            (another review pass)
    |
  "DONE"
    |
    v
6_COMMIT (sonnet)
    |        \
 successful  unsuccessful
    |            \
    |          <result>INCOMPLETE</result>
    v
 rename TASK<n>.md → TASK-DONE-[datetime].md
 commit, push
    |
    v
 more TASK<n>.md files?
    |           \
   yes           no
    |             \
 <reset>       <result>SUCCESS</result>
 1_START
```

## States

### 1_START.md

Entry point. Finds the lowest-numbered task file (`TASK.md`, `TASK1.md`,
`TASK2.md`, etc.) and reads it. Researches the current state of the
codebase before making changes — the task may already be partially
complete from a previous run.

Implements the task but does not stage or commit. Has a single implicit
transition to 2_CHECK_WRAP.

### 2_CHECK_WRAP.sh (script, $0)

A one-line shell script that wraps the review loop in a `<call>`:

```
<call return="5_CHECK_DONE">3_CHECK_FIX.md</call>
```

This is the key structural difference from `bs_work`. By using `<call>`,
the review loop (3_CHECK_FIX / 4_NO_FIX) runs in a branched session,
isolating review noise from the main implementation context. When the
review returns, the result lands at 5_CHECK_DONE.

### 3_CHECK_FIX.md

Review step. The agent reviews all work done so far, looking for
mistakes, errors, or places where there is a better approach. There may
be nothing wrong — the point is to check.

Has a single implicit transition to 4_NO_FIX.

### 4_NO_FIX.md (sonnet)

Decision point after the review. Uses the sonnet model for cost
efficiency. Determines whether the previous review pass actually fixed
anything:

- Something was fixed (major or minor): `<result>SOMETHING FIXED</result>`
- Nothing was fixed (everything is good): `<result>DONE</result>`

Observations marked "not a bug" count as nothing fixed.

### 5_CHECK_DONE.sh (script, $0)

Routing script that inspects `$RAYMOND_RESULT` (the payload from
4_NO_FIX's `<result>` tag) and decides the next step:

- `DONE`: proceeds to 6_COMMIT (`<goto>6_COMMIT.md</goto>`)
- `SOMETHING FIXED` or empty: loops back to 2_CHECK_WRAP for another
  review pass

### 6_COMMIT.md (sonnet)

Final evaluation and commit step. Uses the sonnet model. Examines the
conversation history to determine if the task was successfully completed.

**If unsuccessful or incomplete:**
- Leaves the TASK file in place.
- Leaves files dirty (no staging or commit).
- Terminates with `<result>INCOMPLETE</result>`.

**If successful:**
- Renames the task file to `TASK-DONE-[datetime].md` (including current
  date and time).
- Stages and commits the changes, then pushes.
- Checks for remaining `TASK<number>.md` files.
  - If more tasks exist: resets to 1_START with a fresh context.
  - If no more tasks: terminates with `<result>SUCCESS</result>`.

## Task File Convention

Tasks are defined as markdown files in the working directory:

| File | Priority |
|------|----------|
| `TASK.md` or `TASK1.md` | Highest (picked first) |
| `TASK2.md` | Next |
| `TASK3.md` | Next |
| ... | ... |

The workflow always picks the lowest-numbered file. Completed tasks are
renamed to `TASK-DONE-[datetime].md` to remove them from the queue and
preserve a record of what was done.

## Context Management

The review loop uses a `<call>` / `<result>` boundary to isolate review
context from the main session:

1. **1_START** implements the task, building up implementation context.
2. **2_CHECK_WRAP** issues a `<call>`, branching the session.
3. **3_CHECK_FIX** and **4_NO_FIX** run in the branched session. Review
   observations, false positives, and fix attempts stay contained here.
4. When **4_NO_FIX** returns `<result>`, the branched session is
   discarded.
5. **5_CHECK_DONE** routes back to **2_CHECK_WRAP** for another pass
   (fresh branch each time) or forward to **6_COMMIT**.
6. **6_COMMIT** resumes the main session from step 1, seeing the
   implementation context without the review noise.

This means each review iteration gets a clean branched context, and
the commit step sees the implementation history without accumulated
review chatter.

All transitions back to 1_START use `<reset>` to discard the previous
task's context entirely.

## Model Selection

- **1_START.md**: default model (opus or CLI `--model` setting) — full
  implementation reasoning.
- **3_CHECK_FIX.md**: default model — needs implementation context for
  meaningful review.
- **4_NO_FIX.md**: sonnet — cheap decision: was anything fixed?
- **6_COMMIT.md**: sonnet — cheap evaluation and mechanical commit steps.
- **2_CHECK_WRAP.sh, 5_CHECK_DONE.sh**: shell scripts, $0 cost.

## Commit Conventions

- Do not mention Claude Code as a coauthor or contributor.
- Include "Built with Raymond (Agent Orchestrator)" at the end of the
  commit message.

## Terminal States

| Result | Meaning |
|--------|---------|
| `INCOMPLETE` | A task was attempted but could not be completed successfully. |
| `SUCCESS` | All task files have been processed. |

## Comparison with bs_work

| Aspect | bs_work | taskmd_work |
|--------|---------|-------------|
| Task source | Beads server (`bs` CLI) | TASK markdown files in working directory |
| Task claiming | `bs claim <id>` | Pick lowest-numbered file |
| Task completion | `bs close <id>` | Rename to `TASK-DONE-[datetime].md` |
| Review loop | `goto` cycle (in main session) | `call`/`result` cycle (isolated session) |
| Review decision model | Default | Sonnet (cost optimization) |
| Idle behavior | Terminates with `DONE` | N/A (no server to poll) |
| Commit model | Default | Sonnet |
