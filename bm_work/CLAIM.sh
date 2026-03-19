#!/bin/bash

# Check for an existing in-progress task from a previous run
task_id=$(bm mine 2>/dev/null | jq -r '.beads[0].id // empty' 2>/dev/null)

if [ -n "$task_id" ]; then
    echo "<function return=\"DONE\" input=\"$task_id\">WORK</function>"
    exit 0
fi

# No in-progress task — try to claim one
task_id=$(bm list --ready 2>/dev/null | jq -r '.beads[0].id // empty' 2>/dev/null)

if [ -z "$task_id" ]; then
    echo "<result>DONE</result>"
    exit 0
fi

if bm claim "$task_id" >/dev/null 2>&1; then
    git pull
    echo "<function return=\"DONE\" input=\"$task_id\">WORK</function>"
    exit 0
fi

echo "<result>CLAIM FAILED</result>"
