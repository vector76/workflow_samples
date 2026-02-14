---
allowed_transitions:
  - { tag: goto, target: RE_TEST.md }
  - { tag: result }
---
A `git rebase` has encountered merge conflicts.  Your job is to resolve them.

Examine the conflicted files using `git status` and `git diff`.  For each
conflict, understand what both sides intended and resolve meaningfully — do
not just pick one side blindly.

After resolving all conflicts in a file, stage it with `git add <file>`.

Once all conflicts are resolved, run `git rebase --continue` to complete
the rebase.

If the rebase completes successfully, respond with "<goto>RE_TEST</goto>"
so the code can be verified.

If you cannot resolve the conflicts (they are too complex or contradictory),
abort the rebase with `git rebase --abort` and respond with
"<result>BAIL</result>" to abandon this push attempt.
