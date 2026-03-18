#!/bin/bash
# BAIL_OUT.sh — abandon current work and release the task for another agent
#
# The task ID is expected in RAYMOND_INPUT (set when the CLAIM function was entered).

TASK_ID="$RAYMOND_INPUT"

# Abort any in-progress rebase (safe even if none is in progress)
git rebase --abort 2>/dev/null || true

# Reset local branch to match the current branch's remote head
branch=$(git rev-parse --abbrev-ref HEAD)
git reset --hard "origin/$branch"

# Clean untracked files
git clean -fd

# Delete push attempt counter if it exists
rm -f .raymond/.push_attempts

# Release the task: clear assignee first (prevents race with another agent),
# then set status to open
bm edit "$TASK_ID" --assignee ""
bm edit "$TASK_ID" --status open

echo '<result>BAIL_OUT</result>'
