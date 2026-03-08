#!/bin/bash

if [ "$RAYMOND_RESULT" = "GOOD" ] || [ "$RAYMOND_RESULT" = "BAIL_OUT" ]; then
    echo "<reset>CLAIM</reset>"
else
    echo "<result>$RAYMOND_RESULT</result>"
fi
