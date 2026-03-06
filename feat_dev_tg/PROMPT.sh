#!/bin/bash
set -e
# Send HUMAN_PROMPT.md to the human via tgask and route based on their reply.

tgask ask -t -f HUMAN_PROMPT.md -o HUMAN_RESPONSE.md

if [ ! -f HUMAN_RESPONSE.md ]; then
    # No response written — treat as done.
    echo "<goto>CLEANUP</goto>"
    exit 0
fi

content=$(cat HUMAN_RESPONSE.md)
trimmed=$(printf '%s' "$content" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
last_line=$(printf '%s' "$content" | grep -v '^[[:space:]]*$' | tail -n 1 | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

if [ "$trimmed" = "done" ]; then
    # Response is nothing but "done" — human is finished, no final update needed.
    rm -f HUMAN_PROMPT.md HUMAN_RESPONSE.md
    echo "<goto>CLEANUP</goto>"
elif [ "$last_line" = "done" ]; then
    # Strip the trailing "done" line so downstream receives clean content.
    lineno=$(grep -n '[^[:space:]]' HUMAN_RESPONSE.md | tail -n 1 | cut -d: -f1)
    sed -i "${lineno}d" HUMAN_RESPONSE.md
    echo "<goto>FINAL_RESPONSE</goto>"
else
    # Normal response — update in_progress and continue iterating.
    echo "<goto>RESPONSE</goto>"
fi
