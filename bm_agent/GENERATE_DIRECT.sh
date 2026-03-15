#!/bin/bash

# $RAYMOND_RESULT contains the feature id
result=$(bm fetch "$RAYMOND_RESULT")

mkdir -p ".bm/$RAYMOND_AGENT_ID"

echo "$result" | jq -r '.feature_description' > ".bm/$RAYMOND_AGENT_ID/bm_feature.md"
echo "$RAYMOND_RESULT" > ".bm/$RAYMOND_AGENT_ID/bm_feat_id.txt"

# transition to generating state
bm start-generate "$RAYMOND_RESULT"

echo "<goto input=\"$RAYMOND_AGENT_ID\">GENERATE_DIRECT_2</goto>"
