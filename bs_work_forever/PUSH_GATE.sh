#!/bin/bash
# PUSH_GATE.sh — $0 script state: counter check + call into push attempt
#
# Reads/increments a retry counter. If under the cap, calls FETCH_REBASE.sh
# with return to PUSH.sh (isolating each push attempt in its own session).
# If over the cap, transitions to BAIL_OUT.

COUNTER_FILE=".raymond/.push_attempts"
MAX_ATTEMPTS=5

mkdir -p .raymond

if [ -f "$COUNTER_FILE" ]; then
    count=$(cat "$COUNTER_FILE")
else
    count=0
fi

count=$((count + 1))

if [ "$count" -le "$MAX_ATTEMPTS" ]; then
    echo "$count" > "$COUNTER_FILE"
    echo '<call return="PUSH.sh">FETCH_REBASE.sh</call>'
else
    rm -f "$COUNTER_FILE"
    echo '<goto>BAIL_OUT</goto>'
fi
