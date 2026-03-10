#!/bin/bash

lower=$(echo "${RAYMOND_RESULT}" | tr '[:upper:]' '[:lower:]')

case "$lower" in
    yes) echo "<goto input=\"$RAYMOND_AGENT_ID\">REVIEW_PLAN</goto>" ;;
    no)
        feature_id=$(cat ".bm/$RAYMOND_AGENT_ID/bm_feat_id.txt")
        bm register-artifact "$feature_id" --type plan --file ".bm/$RAYMOND_AGENT_ID/bm_plan.md"
        echo "<reset input=\"$RAYMOND_AGENT_ID\">EXPLORE_CODEBASE</reset>"
        ;;
    *)  echo "<goto input=\"$RAYMOND_AGENT_ID\">REVIEW_PLAN</goto>" ;;
esac
