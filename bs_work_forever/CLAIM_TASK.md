---
allowed_transitions:
  - { tag: goto, target: IMPLEMENT.md }
  - { tag: goto, target: CHECK_DONE.sh }
---
Use `bs mine` to check for current work already in progress (may have been
abandoned from a previous run).

If a task is already in progress, resume it: run `bs show <id>` to get its
full description, then respond with "<goto>IMPLEMENT</goto>" to proceed.

If none are in progress, use `bs list --ready` to identify available tasks.

If no tasks are available, respond with "<goto>CHECK_DONE.sh</goto>"
to enter the polling loop (it will check periodically for new tasks
and never terminate).

If at least one task is available, claim one with `bs claim <id>`.

If the claim fails (e.g., already claimed by another worker), get the ready
list again and try another task.

Once claimed, get its full description with `bs show <id>`.

Do not begin implementation yet.  Respond with "<goto>IMPLEMENT</goto>"
to proceed.
