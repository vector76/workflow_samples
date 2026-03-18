#!/bin/bash
# REBASE.sh — fetch and rebase onto the current branch's remote head
#
# Outcomes:
#   fetch fail  → <goto>BAIL_OUT</goto>   (network/auth failure)
#   clean       → <goto>RETEST</goto>     (rebased cleanly, verify code)
#   conflicts   → <goto>RESOLVE</goto>    (needs conflict resolution)

branch=$(git rev-parse --abbrev-ref HEAD)

if ! git fetch origin >/dev/null 2>&1; then
    echo '<goto>BAIL_OUT</goto>'
    exit 0
fi

git rebase "origin/$branch" >/dev/null 2>&1
exit_code=$?

if [ $exit_code -ne 0 ]; then
    echo '<goto>RESOLVE</goto>'
else
    echo '<goto>RETEST</goto>'
fi
