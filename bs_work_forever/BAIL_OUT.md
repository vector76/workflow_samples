---
allowed_transitions:
  - { tag: reset, target: CLAIM_TASK.md }
---
The push loop has failed (either the retry cap was hit, or a rebase conflict
could not be resolved).  Abandon all current work and release the task so
another agent can attempt it fresh.

Perform the following cleanup steps:

1. Abort any in-progress rebase (safe even if none is in progress):
   `git rebase --abort` (ignore errors)

2. Reset the local branch to match the remote:
   `git reset --hard origin/main`

3. Clean any untracked files:
   `git clean -fd`

4. Delete the push attempt counter if it exists:
   `rm -f .raymond/.push_attempts`

5. Unclaim the task on the beads server (two commands):
   - Clear the assignee: e.g., `bs update <id> --assignee ""`
   - Set status to open: e.g., `bs update <id> --status open`
   (Use the issue ID from earlier in the conversation.)

After cleanup is complete, respond with "<reset>CLAIM_TASK</reset>" to
start fresh on the next available task.
