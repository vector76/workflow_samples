#!/bin/bash

# $RAYMOND_RESULT contains the feature id
result=$(bm fetch "$RAYMOND_RESULT")
echo "$result" | jq -r '.feature_description' > "bm_feature.md"
echo "$RAYMOND_RESULT" > "bm_feat_id.txt"

# transition to generating state
bm start-generate "$RAYMOND_RESULT"

echo "<goto>GENERATE_DRAFT_PLAN</goto>"
