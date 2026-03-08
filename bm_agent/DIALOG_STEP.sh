#!/bin/bash

#  questions empty + response empty + is_final false  →  DIALOG_FIRST
#  questions empty + response empty + is_final true   →  DIALOG_FINALIZE
#  questions/response present + is_final false        →  DIALOG_NEXT
#  questions/response present + is_final true         →  DIALOG_LAST

rm -f bm_feature.md bm_prev_quest.md bm_user.md bm_quest.md bm_feat_id.txt

# $RAYMOND_RESULT contains the feature id
result=$(bm fetch "$RAYMOND_RESULT")
echo "$result" | jq -r '.feature_description' > "bm_feature.md"

echo "$RAYMOND_RESULT" > bm_feat_id.txt
questions=$(echo "$result" | jq -r '.questions')
user_response=$(echo "$result" | jq -r '.user_response')
is_final=$(echo "$result" | jq -r '.is_final')

# questions from the previous round (if any)
if [ -n "$questions" ]; then
    echo "$questions" > "bm_prev_quest.md"
fi

# user response from the previous round (if any)
if [ -n "$user_response" ]; then
    echo "$user_response" > "bm_user.md"
fi

if [ -z "$questions" ] && [ -z "$user_response" ]; then
    if [ "$is_final" = "true" ]; then
        echo -n "" > "bm_quest.md"
        echo "<goto>DIALOG_FINALIZE</goto>"
    else
        echo "<goto>DIALOG_FIRST</goto>"
    fi
elif [ "$is_final" = "true" ]; then
    echo -n "" > "bm_quest.md"
    echo "<goto>DIALOG_LAST</goto>"
else
    echo "<goto>DIALOG_NEXT</goto>"
fi
