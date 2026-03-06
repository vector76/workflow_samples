#!/bin/bash

case "${RAYMOND_RESULT}" in
    SUCCESS)  echo "<reset>START</reset>" ;;   # loop for next file
    DONE)     echo "<result>DONE</result>" ;;   # all done, terminate
    *)        echo "<result>$RAYMOND_RESULT</result>" ;;  # error, abort
esac
