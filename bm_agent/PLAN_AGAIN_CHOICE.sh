#!/bin/bash

lower=$(echo "${RAYMOND_RESULT}" | tr '[:upper:]' '[:lower:]')

case "$lower" in
    yes) echo "<goto>REVIEW_PLAN</goto>" ;;
    no)
          feature_id=$(cat bm_feat_id.txt)
          bm register-artifact "$feature_id" --type plan --file bm_plan.md
          echo "<reset>EXPLORE_CODEBASE</reset>"
          ;;
    *)   echo "<goto>REVIEW_PLAN</goto>" ;;
esac
