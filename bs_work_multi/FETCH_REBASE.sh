#!/bin/bash
# FETCH_REBASE.sh — $0 script state: fetch + rebase + route by outcome
#
# Four outcomes:
#   fetch fail → <result>BAIL</result>          (network/auth failure)
#   clean      → <result>(ok)</result>          (nothing to replay)
#   merged     → <goto>RE_TEST</goto>           (rebased, verify code)
#   conflicts  → <goto>RESOLVE_CONFLICTS</goto> (needs LLM resolution)

if ! git fetch origin >/dev/null 2>&1; then
    # Fetch failed (network issue, auth problem, etc.) — cannot proceed
    echo '<result>BAIL</result>'
    exit 0
fi

rebase_output=$(git rebase origin/main 2>&1)
exit_code=$?

if [ $exit_code -ne 0 ]; then
    # Rebase failed — conflicts
    echo '<goto>RESOLVE_CONFLICTS</goto>'
elif echo "$rebase_output" | grep -qi "up to date"; then
    # Already up to date — nothing replayed
    echo '<result>(ok)</result>'
else
    # Rebased successfully — upstream changes incorporated
    echo '<goto>RE_TEST</goto>'
fi
