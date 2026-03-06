#!/bin/bash

lower=$(echo "${RAYMOND_RESULT}" | tr '[:upper:]' '[:lower:]')

case "$lower" in
    yes) echo "<goto>REVIEW_BEADS</goto>" ;;
    no)  echo "<goto>CREATE_BEADS</goto>" ;;
    *)   echo "<goto>REVIEW_BEADS</goto>" ;;
esac
