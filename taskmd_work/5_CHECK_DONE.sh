#!/bin/bash

if [ -z "$RAYMOND_RESULT" ]; then
    echo "<goto>2_CHECK_WRAP</goto>"
elif [ "$RAYMOND_RESULT" = "DONE" ]; then
    echo "<goto>6_COMMIT.md</goto>"
else
    echo "<goto>2_CHECK_WRAP</goto>"
fi
