$result = "$($env:RAYMOND_RESULT)"

switch ($result) {
    "SUCCESS" { Write-Output "<reset>START</reset>" }   # loop for next file
    "DONE"    { Write-Output "<result>DONE</result>" }  # all done, terminate
    default   { Write-Output "<result>$result</result>" }  # error, abort
}
