#!/bin/bash

lower=$(echo "${RAYMOND_RESULT}" | tr '[:upper:]' '[:lower:]')

case "$lower" in
    yes) echo "<goto input=\"$RAYMOND_AGENT_ID\">REVIEW_BEADS</goto>" ;;
    no)
        feature_id=$(cat ".bm/$RAYMOND_AGENT_ID/bm_feat_id.txt")
        bm register-artifact "$feature_id" --type beads --file ".bm/$RAYMOND_AGENT_ID/bm_beads.md"
        echo "<reset input=\"$RAYMOND_AGENT_ID\">CREATE_BEADS</reset>"
        ;;
    *)  echo "<goto input=\"$RAYMOND_AGENT_ID\">REVIEW_BEADS</goto>" ;;
esac
