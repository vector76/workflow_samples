#!/bin/bash

# claim blocks forever until result is available, and when it's available, 
# it's exclusively allocated to us so another 'bm claim' won't return the same
# item while we're working on it
result=$(bm claim)
action=$(echo "$result" | jq -r '.action')
feature_id=$(echo "$result" | jq -r '.feature_id')
direct_to_bead=$(echo "$result" | jq -r '.direct_to_bead // false')
  
# main thread goes back to START (and then back to CLAIM) while a fresh worker
# goes on to handle the feature
if [ "$action" = "dialog_step" ]; then
    echo "<fork next=\"START\" input=\"$feature_id\">DIALOG_STEP</fork>"
elif [ "$action" = "generate" ]; then
    if [ "$direct_to_bead" = "true" ]; then
        echo "<fork next=\"START\" input=\"$feature_id\">GENERATE_DIRECT</fork>"
    else
        echo "<fork next=\"START\" input=\"$feature_id\">GENERATE</fork>"
    fi
elif [ "$action" = "timeout" ]; then
    echo "<reset>START</reset>"
else
    echo "<reset>START</reset>"
fi
