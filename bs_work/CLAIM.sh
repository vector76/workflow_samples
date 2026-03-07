#!/bin/bash
# Assumes `bs mine` and `bs list --ready` return a JSON array of objects with an `id` field.

# Check for an existing in-progress task from a previous run
task_id=$(bs mine 2>/dev/null | jq -r '.beads[0].id // empty' 2>/dev/null)

if [ -n "$task_id" ]; then
    echo "<function return=\"DONE\" input=\"$task_id\">WORK</function>"
    exit 0
fi

# No in-progress task — try to claim one, up to 3 attempts
for attempt in 1 2 3; do
    task_id=$(bs list --ready 2>/dev/null | jq -r '.beads[0].id // empty' 2>/dev/null)

    if [ -z "$task_id" ]; then
        echo "<result>DONE</result>"
        exit 0
    fi

    if bs claim "$task_id" >/dev/null 2>&1; then
        echo "<function return=\"DONE\" input=\"$task_id\">WORK</function>"
        exit 0
    fi
done

echo "<result>CLAIM FAILED</result>"
