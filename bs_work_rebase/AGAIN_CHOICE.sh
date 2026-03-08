#!/bin/bash

if [ "$RAYMOND_RESULT" = "YES" ]; then
    echo "<goto>REVIEW</goto>"
else
    echo "<goto>COMMIT</goto>"
fi
