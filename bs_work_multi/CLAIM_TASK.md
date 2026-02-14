---
allowed_transitions:
  - { tag: goto, target: IMPLEMENT.md }
  - { tag: result }
---
Use `bs mine` to check for current work already in progress (may have been
abandoned from a previous run).

If none are in progress, then use `bs list --ready` to identify available tasks.

If no tasks are available, then respond with "<result>DONE</result>"

If at least one task is available, claim one with `bs claim <id>`.

If the claim fails (e.g., already claimed by another worker), get the ready
list again and try another task.

Then get its full description with `bs show <id>`.

Do not begin implementation yet.  Once you have the full description of the
task, stop.  Respond with "<goto>IMPLEMENT</goto>" to proceed.
