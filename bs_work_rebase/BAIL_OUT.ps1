# BAIL_OUT.ps1 — abandon current work and release the task for another agent
#
# The task ID is expected in RAYMOND_INPUT (set when the CLAIM function was entered).

$TaskId = $env:RAYMOND_INPUT

# Abort any in-progress rebase (safe even if none is in progress)
git rebase --abort 2>$null

# Reset local branch to match the current branch's remote head
$branch = git rev-parse --abbrev-ref HEAD
git reset --hard "origin/$branch"

# Clean untracked files
git clean -fd

# Delete push attempt counter if it exists
Remove-Item -Path ".raymond/.push_attempts" -Force -ErrorAction SilentlyContinue

# Release the task: clear assignee first (prevents race with another agent),
# then set status to open
bs update $TaskId --assignee ""
bs update $TaskId --status open

Write-Output '<result>BAIL_OUT</result>'
