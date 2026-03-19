#!/bin/bash
if [ "$RAYMOND_RESULT" = "also_agent" ]; then
    echo "<fork-workflow next=\"START2\">../bm_agent/</fork-workflow>"
else
    echo "<goto>START2</goto>"
fi
