#!/bin/bash

if bm list >/dev/null 2>&1; then
    echo "<goto>CLAIM</goto>"
else
    sleep 10
    echo "<result>NOT CONFIGURED</result>"
fi
