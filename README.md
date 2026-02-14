# Raymond Workflow Samples

Sample workflows for [Raymond](https://github.com/anthropics/raymond), an agent orchestrator that automates AI coding agents like Claude Code.

Raymond treats workflows as state machines where each state is a markdown prompt (`.md`) or a shell script (`.sh`). States declare their own transitions using XML tags (`<goto>`, `<reset>`, `<call>`, `<result>`, etc.), and Raymond's orchestrator interprets these tags to drive the workflow forward.

## Workflows

### bs_work — Beads Server Work Loop

Pulls tasks from [Beads Server](https://github.com/vector76/beads_server) using the `bs` CLI, implements them, self-reviews, and commits. Loops back to pick up the next task until the backlog is empty.

```
1_START.md ──goto──> 2_IMPL.md ──goto──> 3_CHECK_FIX.md ──goto──> 4_NO_FIX.md
                                              ^                     │
                                              │ (something fixed)   │
                                              └─────────────────────┘
                                                                    │ (nothing to fix)
                                                                    v
                                                              5_COMMIT.md
                                                                    │
                                                    (more tasks) ───┘──reset──> 1_START.md
                                                    (no tasks)   ───┘──result──> done
```

| State | Description |
|-------|-------------|
| `1_START.md` | Check for in-progress work (`bs mine`), or claim a new task (`bs claim`) |
| `2_IMPL.md` | Implement the task; do not close the backlog item yet |
| `3_CHECK_FIX.md` | Self-review: look for mistakes, errors, or improvements |
| `4_NO_FIX.md` | Evaluate whether the review found anything worth fixing. Loop back to review if yes, proceed to commit if no |
| `5_COMMIT.md` | Commit, push, and resolve the backlog item. Reset to `1_START.md` if more tasks remain |

### taskmd_work — TASK.md File Work Loop

Reads numbered `TASK<n>.md` files from the working directory, implements them one at a time with a self-review loop, and commits. Uses shell script states for zero-cost control flow decisions.

```
1_START.md ──goto──> 2_CHECK_WRAP.sh ──call──> 3_CHECK_FIX.md ──goto──> 4_NO_FIX.md
                          ^                                                  │
                          │                                          result (SOMETHING FIXED
                          │                                           or DONE)
                          │                                                  v
                          │                                          5_CHECK_DONE.sh
                          │  (SOMETHING FIXED)                               │
                          └──────────────────────────────────────────────────-┘
                                                                (DONE)       │
                                                                             v
                                                                       6_COMMIT.md
                                                                             │
                                                             (more tasks) ───┘──reset──> 1_START.md
                                                             (no tasks)   ───┘──result──> done
```

| State | Description |
|-------|-------------|
| `1_START.md` | Find the lowest-numbered `TASK<n>.md` file and implement it |
| `2_CHECK_WRAP.sh` | Shell script that invokes the review step via `<call>`, routing the result to `5_CHECK_DONE.sh` |
| `3_CHECK_FIX.md` | Self-review: look for mistakes or improvements |
| `4_NO_FIX.md` | Evaluate whether fixes were applied. Returns `SOMETHING FIXED` or `DONE` |
| `5_CHECK_DONE.sh` | Shell script that routes based on the review result — loop back for more review or proceed to commit |
| `6_COMMIT.md` | Commit, push, and rename the task file to `TASK-DONE-[datetime].md`. Reset to `1_START.md` if more tasks remain |

This workflow demonstrates **hybrid script/markdown states** — shell scripts handle deterministic branching at zero token cost, while markdown states handle the work that requires LLM reasoning.

### human_prd — Interactive PRD Refinement

An interactive loop where the agent drafts or refines a PRD (`PRD.md`), then pauses for human input before continuing. The agent writes questions or assumptions to `HUMAN_PROMPT.md` with a `<!-- COMPOSING -->` marker appended at the end. The script `2_PROMPT.sh` uses `inotifywait` to block until that marker is removed, then inspects the file contents to decide what to do next.

**What the human does:**

1. Open `HUMAN_PROMPT.md` in an editor. The agent's questions/assumptions will be there, followed by a `<!-- COMPOSING -->` marker.
2. Write your answers or clarifications in the file.
3. **Delete the `<!-- COMPOSING -->` line** and save. This signals that your input is ready, and the agent will process your response and loop back for another round.
4. To **end the conversation**, delete all contents of the file (leave it empty), remove the `<!-- COMPOSING -->` line, and save. The agent will treat an empty file as "done" and terminate.

```
1_START.md ──goto──> 2_PROMPT.sh ──(wait for human)──> 3_RESPONSE.md ──reset──> 1_START.md
                          │
                          │ (human saves empty file)
                          v
                     4_CLEANUP.sh ──result──> done
```

| State | Description |
|-------|-------------|
| `1_START.md` | Read `PRD.md` (if it exists) and write questions or assumptions to `HUMAN_PROMPT.md` |
| `2_PROMPT.sh` | Appends `<!-- COMPOSING -->` to the file, then blocks until the human removes that marker. If the file has content, proceeds to `3_RESPONSE.md`. If the file is empty, proceeds to `4_CLEANUP.sh` |
| `3_RESPONSE.md` | Read the human's clarifications from `HUMAN_PROMPT.md` and use them to refine or create `PRD.md` |
| `4_CLEANUP.sh` | Delete `HUMAN_PROMPT.md` and terminate |

## Raymond Concepts Used

These samples exercise several key Raymond features:

| Feature | Description | Used In |
|---------|-------------|---------|
| `<goto>` | Continue in the same context (session preserved) | All workflows |
| `<reset>` | Discard context and start fresh | `bs_work`, `taskmd_work` (loop back for next task) |
| `<result>` | Return a value / terminate the agent | All workflows |
| `<call>` | Invoke a sub-workflow and return the result | `taskmd_work` (review loop) |
| Shell script states (`.sh`) | Zero-cost deterministic control flow | `taskmd_work`, `human_prd` |
| YAML frontmatter | Declare allowed transitions and model selection | All `.md` states |
| `model: sonnet` | Use a cheaper model for simple evaluation steps | `taskmd_work` (`4_NO_FIX.md`, `6_COMMIT.md`) |
| `{{result}}` / `RAYMOND_RESULT` | Template variable for receiving return values | `taskmd_work` (`5_CHECK_DONE.sh`) |

## Running a Workflow

```bash
# Start a workflow by pointing Raymond at the first state file
raymond bs_work/1_START.md
raymond taskmd_work/1_START.md
raymond human_prd/1_START.md

# With options
raymond taskmd_work/1_START.md --model sonnet --budget 5.00
raymond bs_work/1_START.md --dangerously-skip-permissions
```

## Prerequisites

- [Raymond](https://github.com/anthropics/raymond) installed and on your PATH
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed (Raymond invokes it under the hood)
- For `bs_work`: the `bs` CLI from [Beads Server](https://github.com/vector76/beads_server) installed and configured
- For `taskmd_work`: one or more `TASK.md` / `TASK1.md` / `TASK2.md` files in the working directory
- For `human_prd`: `inotifywait` available (from `inotify-tools` on Linux)
