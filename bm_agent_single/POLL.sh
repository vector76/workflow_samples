#!/bin/bash

# poll blocks forever until result is available
result=$(bm poll)
action=$(echo "$result" | jq -r '.action')
feature_id=$(echo "$result" | jq -r '.feature_id')

if [ "$action" = "dialog_step" ]; then
    echo "<goto input=\"$feature_id\">DIALOG_STEP</goto>"
elif [ "$action" = "generate" ]; then
    echo "<goto input=\"$feature_id\">GENERATE</goto>"
elif [ "$action" = "timeout" ]; then
    echo "<result>Timeout, try again</result>"
else
    echo "<result>Unrecognized poll result</result>"
fi
