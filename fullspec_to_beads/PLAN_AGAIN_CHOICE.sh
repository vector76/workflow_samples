#!/bin/bash

lower=$(echo "${RAYMOND_RESULT}" | tr '[:upper:]' '[:lower:]')

case "$lower" in
    yes) echo "<goto>REVIEW_PLAN</goto>" ;;
    no)  echo "<goto>TRANSITION</goto>" ;;
    *)   echo "<goto>REVIEW_PLAN</goto>" ;;
esac
