#!/bin/bash
# CHECK_DONE.sh — $0 script state: poll for work or terminate
#
# Called when CLAIM_TASK finds nothing ready. Polls periodically:
#   1. Check bs list --ready — if any ready, reset to CLAIM_TASK
#   2. Check bs list --status open — if any open (possibly blocked), sleep and retry
#   3. Nothing open — all work is closed or in-progress, terminate
#
# Polling interval: 3 minutes

POLL_INTERVAL=180

# Check if any tasks are ready to claim right now
ready_count=$(bs list --ready 2>/dev/null | wc -l)
if [ "$ready_count" -gt 0 ]; then
    echo '<reset>CLAIM_TASK</reset>'
    exit 0
fi

# Check if any tasks are open (including blocked)
open_count=$(bs list --status open 2>/dev/null | wc -l)
if [ "$open_count" -gt 0 ]; then
    # Open tasks exist but none are ready — they may become unblocked
    # when other agents complete their work. Wait and check again.
    sleep $POLL_INTERVAL
    echo '<goto>CHECK_DONE.sh</goto>'
    exit 0
fi

# Nothing open — all tasks are either closed or in-progress.
# This worker is surplus. Terminate.
echo '<result>DONE</result>'
