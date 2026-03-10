#!/bin/bash

lower=$(echo "${RAYMOND_RESULT}" | tr '[:upper:]' '[:lower:]')

case "$lower" in
    yes) echo "<goto>REVIEW_BEADS</goto>" ;;
    no)
          feature_id=$(cat bm_feat_id.txt)
          bm register-artifact "$feature_id" --type beads --file bm_beads.md
          echo "<reset>CREATE_BEADS</reset>"
          ;;
    *)   echo "<goto>REVIEW_BEADS</goto>" ;;
esac
