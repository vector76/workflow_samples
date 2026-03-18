#!/bin/bash
# PUSH_ATTEMPT.sh — attempt git push with retry counter
#
# Increments a counter each attempt. If over the cap, goto BAIL_OUT.
# On successful push, goto CLOSE_TASK.
# On rejection (non-fast-forward), goto REBASE.

COUNTER_FILE=".raymond/.push_attempts"
MAX_ATTEMPTS=5

mkdir -p .raymond

if [ -f "$COUNTER_FILE" ]; then
    count=$(cat "$COUNTER_FILE")
else
    count=0
fi

count=$((count + 1))

if [ "$count" -gt "$MAX_ATTEMPTS" ]; then
    rm -f "$COUNTER_FILE"
    echo '<goto>BAIL_OUT</goto>'
    exit 0
fi

echo "$count" > "$COUNTER_FILE"

if git push origin HEAD >/dev/null 2>&1; then
    rm -f "$COUNTER_FILE"
    echo '<goto>CLOSE_TASK</goto>'
else
    echo '<goto>REBASE</goto>'
fi
