---
allowed_transitions:
  - { tag: reset, target: CLAIM_TASK.md }
  - { tag: result }
---
The work has been pushed successfully.  Close the task on the beads server.

Run `bs close <id>` using the issue ID from earlier in the conversation.

After closing, check if there are more tasks with `bs list --ready`.
- If there are more tasks, respond with "<reset>CLAIM_TASK</reset>".
- If there are no more tasks, respond with "<result>DONE</result>".
