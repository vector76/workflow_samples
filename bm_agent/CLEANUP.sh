#!/bin/bash

if [[ -z "$RAYMOND_AGENT_ID" ]]; then
    # prevent over-zealous delete if we somehow lost the feature ID
    echo "Error: RAYMOND_AGENT_ID is not set" >&2
    exit 1
fi

rm -rf ".bm/$RAYMOND_AGENT_ID"

# forked worker terminates
echo "<result>$RAYMOND_RESULT</result>"
