#!/bin/bash

if [ -f "STOP_REQUESTED" ]; then
    echo "<result>STOP REQUESTED</result>"
else
    sleep 1
    echo "<reset>CLAIM</reset>"
fi
