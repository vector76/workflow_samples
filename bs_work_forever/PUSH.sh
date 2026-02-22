#!/bin/bash
# PUSH.sh — $0 script state: check call result + push or route
#
# Receives RAYMOND_RESULT from the call branch and routes:
#   (ok)    → try git push; success → CLOSE_TASK, rejected → PUSH_GATE.sh
#   REWORK  → delete counter, goto RUN_TESTS (re-enter review loop)
#   BAIL    → goto BAIL_OUT (abandon work)

COUNTER_FILE=".raymond/.push_attempts"

case "$RAYMOND_RESULT" in
    "(ok)")
        if git push origin HEAD >/dev/null 2>&1; then
            rm -f "$COUNTER_FILE"
            echo '<goto>CLOSE_TASK</goto>'
        else
            echo '<goto>PUSH_GATE.sh</goto>'
        fi
        ;;
    "REWORK")
        rm -f "$COUNTER_FILE"
        echo '<goto>RUN_TESTS</goto>'
        ;;
    "BAIL")
        echo '<goto>BAIL_OUT</goto>'
        ;;
    *)
        # Unexpected result — bail out
        echo '<goto>BAIL_OUT</goto>'
        ;;
esac
