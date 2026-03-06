#!/bin/bash

if [ "$RAYMOND_RESULT" = "GOOD" ]; then
    echo "<reset>CLAIM</reset>"
else
    echo "<result>$RAYMOND_RESULT</result>"
fi
