---
allowed_transitions:
  - { tag: goto, target: RETEST }
  - { tag: goto, target: BAIL_OUT }
---
A `git rebase` has encountered merge conflicts.  Your job is to resolve them.

Examine the conflicted files using `git status` and `git diff`.  For each
conflict, understand what both sides intended and resolve meaningfully — do
not just pick one side blindly.

After resolving all conflicts in a file, stage it with `git add <file>`.

Once all conflicts are resolved, run `git rebase --continue`.  If the
rebase has multiple commits to replay, `--continue` may stop again with
new conflicts on a subsequent commit.  Repeat the resolve/add/continue
cycle until the rebase finishes completely.

If the rebase completes successfully, respond with `<goto>RETEST</goto>`
so the code can be verified.

If the conflicts are too complex or contradictory to resolve, abort the
rebase with `git rebase --abort` and respond with `<goto>BAIL_OUT</goto>`
to abandon this task and release it for another agent.
