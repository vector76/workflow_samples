# bs_work_multi

## Overview

A variant of the `bs_work` workflow designed to run as multiple independent
Raymond instances in parallel, each in its own directory with a separate
checkout of the project. Each instance claims tasks from the beads server,
implements them, and pushes — coordinating only at `git push` time via a
rebase loop.

## Motivation

The original `bs_work` workflow is serial: claim a task, implement, review,
commit, push, resolve, then claim the next task. With `bs_work_multi`, we
run N instances concurrently to increase throughput. Each instance is fully
independent — no shared state, no Raymond-level coordination. The only
point of coordination is the git remote.

## Deployment Model

- Each instance runs in its own directory with its own git clone (or worktree)
  of the target repository.
- Each instance runs its own `ray` process with this workflow.
- The beads server (`bs`) handles task partitioning — no two instances will
  claim the same task.
- All instances push to the same remote branch (e.g., `main`).

## Workflow per Instance

```
1_START
    |
    v
CLAIM_TASK ←─────────────────────────────────────────────┐
    |       \                                            |
    |    nothing ready                                   |
    |         \                                          |
    v          v                                         |
IMPLEMENT   CHECK_DONE.sh ·······  $0 script: poll loop  |
              |        \                                 |
           open tasks   nothing open                     |
           exist (wait)    \                             |
              |             v                            |
           sleep 3m    <result>DONE</result>             |
              |                                          |
              v                                          |
           (check ready ─── ready found ─────────────────┘
            again)              (<reset>)
              |
              v
           (check open ─── still open → sleep again)
              |
              v
           (nothing open → <result>DONE</result>)
    |
    v
CHECK_FIX  ←──────────────────────────────────┐
    |                                          |
    v                                          |
NO_FIX ───→ (loop back if fixes were made) ────┘
    |
    v
COMMIT
    |        \
    |      unsuccessful
    |          \
    |        BAIL_OUT ──→ CLAIM_TASK  (<reset>)
    |
  successful
    |
    v
PUSH_GATE.sh ··················  $0 script: counter check
    |      \
    |    over cap → BAIL_OUT ─→ CLAIM_TASK  (<reset>)
    |
  under cap
    |
    | <call return="PUSH.sh">FETCH_REBASE.sh</call>
    |
    |   call branch (isolated session, discarded after <result>)
    |   ·······················································
    |   :                                                     :
    |   :  FETCH_REBASE.sh ·········  $0 script: fetch+rebase :
    |   :     |        |        \                             :
    |   :     |        |      conflicts                       :
    |   :     |        |          \                            :
    |   :     |        |     RESOLVE_CONFLICTS  (LLM)         :
    |   :     |        |        |            \                 :
    |   :     |        |     resolved      unresolved          :
    |   :     |        |        |              \               :
    |   :     |      merged     |        <result>BAIL</result> :
    |   :     |        \        |                              :
    |   :     |         v       v                              :
    |   :     |         RE_TEST  (LLM, single state)          :
    |   :     |          |          \                          :
    |   :     |        pass        fail                        :
    |   :     |          |            \                        :
    |   :     v          v             v                       :
    |   :   clean  <result>(ok)  <result>REWORK</result>      :
    |   :     |                                                :
    |   :     v                                                :
    |   :   <result>(ok)</result>                               :
    |   ·······················································
    |
    v
  PUSH.sh ·····················  $0 script: check result + route
      |           |          \
   result=ok   REWORK       BAIL
      |           |            \
   try push       |          BAIL_OUT ──→ CLAIM_TASK  (<reset>)
    / \           |
   v   v          v
 success rejected  RUN_TESTS ──→ CHECK_FIX  (rework loop)
   |       \
   v        v
CLOSE     PUSH_GATE.sh
 TASK       (next attempt)
   |
   v (<reset>)
CLAIM_TASK
```

**Three rebase outcomes, three result values, one call boundary:**

PUSH_GATE.sh uses `<call return="PUSH.sh">FETCH_REBASE.sh</call>`.
The call branch is the disposable part — all rebase work happens in
an isolated session. The return destination (PUSH.sh) is where
control lands after any `<result>`, with the isolated session
discarded.

- **Clean** (already up to date): FETCH_REBASE.sh immediately emits
  `<result>(ok)</result>`. No LLM invocation at all.
- **Merged** (rebased, no conflicts): FETCH_REBASE.sh gotos RE_TEST
  (LLM verifies the combined code).
  - Tests pass: `<result>(ok)</result>`
  - Tests fail: `<result>REWORK</result>`
- **Conflicts** (rebase halted): FETCH_REBASE.sh gotos
  RESOLVE_CONFLICTS (LLM resolves and continues the rebase).
  - Resolved successfully: gotos RE_TEST (same pass/fail as above).
  - Unresolved (dirty git state after attempt): aborts the rebase
    and emits `<result>BAIL</result>`.

PUSH.sh receives the result and routes:

- **ok** → attempt `git push`.
  - Success → CLOSE_TASK → `<reset>CLAIM_TASK</reset>`.
  - Rejected (non-fast-forward) → PUSH_GATE.sh (next iteration).
- **REWORK** → delete counter file, goto RUN_TESTS → CHECK_FIX
  (re-enter the review loop to fix post-rebase issues, then
  re-commit and re-enter the push loop).
- **BAIL** → goto BAIL_OUT (abandon work, unclaim task).

**CLOSE_TASK**: An LLM state that runs `bs close <id>` on the task
(using the issue ID from session context), then transitions with
`<reset>CLAIM_TASK</reset>`. Closing the task automatically releases
any dependent tasks on the beads server. CLAIM_TASK then either
claims the next ready task or enters the CHECK_DONE.sh polling loop.

**Script vs. LLM states**: PUSH_GATE.sh, FETCH_REBASE.sh, PUSH.sh,
and CHECK_DONE.sh are shell scripts ($0 cost). 1_START, CLAIM_TASK,
IMPLEMENT, CHECK_FIX, NO_FIX, COMMIT, RESOLVE_CONFLICTS, RE_TEST,
RUN_TESTS, BAIL_OUT, CLOSE_TASK are LLM states.

## Key Differences from bs_work

### 1. Commit and push are separated

In `bs_work`, state `5_COMMIT` does `git add`, `git commit`, and `git push`
in one step. Here, the local commit happens first, and then a separate
push loop handles getting the commit onto the remote.

### 2. Rebase loop with three outcomes

After committing locally, the instance enters a push loop.
PUSH_GATE.sh checks the retry counter and, if under the cap, emits
`<call return="PUSH.sh">FETCH_REBASE.sh</call>`. FETCH_REBASE.sh
does `git fetch origin` and `git rebase origin/main`, then routes
based on the outcome:

1. **Clean** (already up to date): Nothing was replayed, no code
   changed. Emit `<result>(ok)</result>` immediately — no LLM needed.
2. **Merged** (rebased, no conflicts): Upstream commits were
   incorporated under our work. Goto RE_TEST (LLM verifies), which
   emits `<result>(ok)</result>` or `<result>REWORK</result>`.
3. **Conflicts** (rebase halted): Goto RESOLVE_CONFLICTS (LLM
   resolves). If resolved, goto RE_TEST. If unresolved, abort the
   rebase and emit `<result>BAIL</result>`.

All paths emit `<result>`, which lands at PUSH.sh (the call's return
destination). PUSH.sh inspects the result payload and routes
accordingly.

### 3. Re-testing after rebase

A successful rebase (no textual conflicts) can still produce broken
code. Example: Agent A renames a function, Agent B (on a stale base)
adds a call to the old name. The rebase succeeds textually but the
code won't compile.

Re-testing is only needed when the rebase actually changed something
(merged or conflict cases). A clean rebase (already up to date) means
nothing changed, so the previously-passing tests are still valid.

If RE_TEST detects failures, it emits `<result>REWORK</result>`.
PUSH.sh then routes back to the review loop (RUN_TESTS → CHECK_FIX)
so the LLM can fix the post-rebase issues, re-commit, and try the
push loop again.

### 4. Conflict resolution as a deliberate step

When `git rebase` hits conflicts, the workflow enters a dedicated
LLM state (RESOLVE_CONFLICTS). This gives the LLM full context to
understand what both sides intended, resolve the conflict
meaningfully (not just pick a side), and continue the rebase.

RESOLVE_CONFLICTS must leave git in a clean state before
transitioning. If it successfully resolves all conflicts, it runs
`git rebase --continue` and gotos RE_TEST. If it cannot resolve,
it runs `git rebase --abort` and emits `<result>BAIL</result>`.

### 5. Retry cap on the push loop

To prevent an agent from spinning forever on a persistent conflict or
an unresolvable situation, the push loop has a maximum retry count
(e.g., 3-5 attempts).

**Implementation**: The entry point to the push loop is a **shell script
state** (`PUSH_GATE.sh`). This script:

1. Reads a counter file (`.raymond/.push_attempts`) in the working
   directory. If the file doesn't exist, initializes it to 0.
2. Increments the counter.
3. If under the cap: writes the updated counter back to the file and
   emits `<call return="PUSH.sh">FETCH_REBASE.sh</call>`.
4. If over the cap: deletes the counter file and transitions to
   `BAIL_OUT`.

PUSH.sh handles the other end:
- On a successful push: deletes the counter file and transitions to
  CLOSE_TASK.
- On a rejected push: transitions back to PUSH_GATE.sh for the next
  iteration.
- On REWORK: deletes the counter file (the code is about to change,
  so previous push failures are no longer relevant) and routes to
  RUN_TESTS → CHECK_FIX for rework. After rework, COMMIT creates a
  new commit and re-enters PUSH_GATE.sh with a fresh counter.
- On BAIL: transitions to BAIL_OUT.

Shell script states are $0 cost (no LLM invocation) and deterministic,
making them ideal for counter/routing logic. The counter file is in the
`.raymond/` directory, local to each instance's checkout.

### 6. Rework path

When RE_TEST detects failures after a rebase, PUSH.sh routes to
RUN_TESTS — an LLM state that instructs the agent to re-run the
project's test suite. The test output is then in the LLM session
context when it gotos CHECK_FIX, so the LLM knows exactly what
failed and can fix the issues.

The rework path re-enters the existing CHECK_FIX → NO_FIX review
loop. After fixing, COMMIT creates a new commit (on top of the
rebased work) and the push loop starts over with a fresh counter.

Multiple local commits (original implementation + rework fixes) are
fine — `git rebase origin/main` replays all of them on top of the
remote head, regardless of how many there are.

### 7. Bail-out: discard and unclaim

When the retry cap is hit, or RESOLVE_CONFLICTS can't resolve, or
PUSH.sh receives a BAIL result, the agent enters BAIL_OUT. This is
an LLM state that instructs the agent to perform a universal cleanup.
The prompt provides command-line hints for the likely operations:

1. Abort any in-progress rebase (e.g., `git rebase --abort`; safe to
   run even if no rebase is in progress).
2. Reset the local branch to match the remote
   (e.g., `git reset --hard origin/main`), discarding all local
   commits.
3. Clean any untracked files (e.g., `git clean -fd`).
4. Delete the counter file if it exists
   (e.g., `rm -f .raymond/.push_attempts`).
5. Unclaim the task on the beads server (two sequential commands):
   - Clear the assignee (e.g., `bs update <id> --assignee ""`).
   - Set status to open (e.g., `bs update <id> --status open`).
   There is a small window between these two commands where a crash
   would leave the task in-progress with no assignee. This risk is
   accepted.
6. Transition to `<reset>CLAIM_TASK</reset>` to start fresh on
   the next task.

This means a task that repeatedly fails to push will eventually be
retried by any agent from a fresh copy of the remote. Since the
fresh base includes all the commits that were causing conflicts, the
retry is likely to succeed.

### 8. Polling loop when idle

When CLAIM_TASK finds no ready tasks, instead of terminating
immediately it transitions to CHECK_DONE.sh — a $0 polling script
that periodically checks for work:

1. `bs list --ready` — any ready? → `<reset>CLAIM_TASK</reset>`
2. `bs list --status open` — any open (possibly blocked)? → sleep
   3 minutes and loop. These tasks may become unblocked when other
   agents close their work, releasing dependents.
3. Nothing open (all closed or in-progress) → `<result>DONE</result>`.
   All remaining work is either finished or actively being handled
   by other agents. This worker is surplus.

This prevents workers from terminating prematurely when blocked tasks
exist that could become ready. It also ensures workers terminate
naturally when all work is complete, rather than polling forever.

### 9. Claim tolerance

With multiple instances calling `bs list --ready` and `bs claim`
concurrently, two instances may try to claim the same task. Since
claiming is atomic (sets assignee and marks in-progress in one
operation), only one will succeed. The CLAIM_TASK prompt instructs
the LLM to handle a failed claim gracefully — get the ready list
again and try another task.

## Context Management

The `<call return="PUSH.sh">FETCH_REBASE.sh</call>` boundary in
PUSH_GATE.sh serves dual purposes: it routes control flow and it
isolates context.

Each push attempt may involve conflict resolution diffs, test output,
and git diagnostics — potentially thousands of tokens. Without
isolation, this would accumulate across retries. With the call
boundary, the entire attempt runs in an isolated session that is
discarded when `<result>` is emitted. PUSH.sh and PUSH_GATE.sh
(both scripts) have no session of their own, so the only LLM context
that persists across the push loop is the implementation session from
CLAIM_TASK through COMMIT.

This means:
- Attempt 3 has zero context noise from attempts 1 and 2.
- RESOLVE_CONFLICTS and RE_TEST get a clean session focused on the
  current state of the code, not polluted by previous failed attempts.
- The clean path (no rebase needed) creates no LLM session at all —
  it goes FETCH_REBASE.sh → `<result>` → PUSH.sh, entirely in
  script states.

All transitions back to CLAIM_TASK use `<reset>` to discard the
previous task's context and start a fresh session.

## Design Considerations

### Task independence

The approach works best when tasks touch different files. If tasks
frequently modify the same files (shared config, central registries,
route tables), rebase conflicts will be common and the agents will spend
time resolving them rather than doing productive work. Task design and
decomposition is the best lever for making this run smoothly.

### Number of parallel instances

There is no hard limit, but practical considerations apply:
- More instances = more frequent push contention
- Each instance needs its own disk space (full clone or worktree)
- The beads server must have enough tasks to keep all instances busy
- 2-5 instances is a practical starting point

### What the beads server handles

The beads server manages the shared state of all tasks and
coordinates between instances. Each instance interacts with it
via the `bs` CLI.

- Task assignment (claim) is atomic — sets assignee and marks
  in-progress in one operation, preventing two agents from claiming
  the same task.
- Task lifecycle: open → in-progress → closed.
- `bs close` closes a completed task. Unclaiming (for bail-out)
  requires two commands: clear assignee, then set status to open.

### Failure modes

- **Rebase conflict that can't be auto-resolved**: RESOLVE_CONFLICTS
  aborts the rebase and returns BAIL. PUSH.sh routes to BAIL_OUT
  which unclaims the task and resets. The next agent to claim it
  starts fresh on top of the current remote.
- **Tests fail after rebase**: RE_TEST returns REWORK. PUSH.sh routes
  back to the review loop. The LLM fixes the issues, re-commits,
  and tries the push loop again with a fresh counter.
- **Push keeps getting rejected**: The retry cap prevents infinite
  loops. After the cap is hit, BAIL_OUT unclaims the task.
- **Instance crashes mid-work**: The beads task stays in-progress
  with an assignee. The `bs mine` check at startup handles
  resumption (same as `bs_work`).
- **Crash during unclaim**: If the agent crashes between clearing the
  assignee and setting status to open, the task is left in-progress
  with no assignee (limbo). This is a known, accepted risk — low
  probability and detectable by monitoring.
- **Task cycles through repeated bail-outs**: This is self-correcting.
  Each retry starts from the latest remote, which includes more of the
  conflicting work. Eventually the conflicts diminish and the task
  lands. If a task is fundamentally broken (e.g., incompatible with
  other changes), it will keep cycling — but this is visible in the
  beads server history and can be caught by monitoring.
