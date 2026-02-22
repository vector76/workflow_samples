#!/bin/bash
# CHECK_DONE.sh — $0 script state: poll for work indefinitely
#
# Called when CLAIM_TASK finds nothing ready. Loops internally until
# a ready task appears — never emits a self-transition, never terminates.
#
# Polling interval: 3 minutes

POLL_INTERVAL=180

while true; do
    ready_beads=$(bs list --ready 2>/dev/null | jq -r '.beads')
    if [ "$ready_beads" != "[]" ]; then
        echo '<reset>CLAIM_TASK</reset>'
        exit 0
    fi
    sleep $POLL_INTERVAL
done
