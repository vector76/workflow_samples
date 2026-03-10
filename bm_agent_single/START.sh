#!/bin/bash

if [ -f "STOP_REQUESTED" ]; then
    echo "<result>STOP REQUESTED</result>"
else
    echo "<function return=\"OUTER_LOOP\">POLL</function>"
fi
