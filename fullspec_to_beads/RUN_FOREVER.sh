#!/bin/bash

# Abort if the previous batch ended with an error
case "${RAYMOND_RESULT}" in
    DONE|"") ;;  # normal completion or first call, continue
    *)  echo "<result>$RAYMOND_RESULT</result>"; exit 0 ;;
esac

# Sleep between polling cycles (but not on the very first call)
if [ -n "$RAYMOND_RESULT" ]; then
    sleep 30
fi

echo "<function return=\"RUN_FOREVER\">START</function>"
