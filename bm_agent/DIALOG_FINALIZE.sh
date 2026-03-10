#!/bin/bash

if [[ -z "$RAYMOND_AGENT_ID" ]]; then
    # prevent over-zealous delete if we somehow lost the feature ID
    echo "Error: RAYMOND_AGENT_ID is not set" >&2
    exit 1
fi
  
feature_id=$(cat ".bm/$RAYMOND_AGENT_ID/bm_feat_id.txt")
bm submit "$feature_id" --description ".bm/$RAYMOND_AGENT_ID/bm_feature.md" --questions ".bm/$RAYMOND_AGENT_ID/bm_quest.md"
rm -rf ".bm/$RAYMOND_AGENT_ID"

# forked worker terminates
echo "<result>DONE</result>"
