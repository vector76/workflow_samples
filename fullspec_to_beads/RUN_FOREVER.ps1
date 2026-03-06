$result = "$($env:RAYMOND_RESULT)"

# Abort if the previous batch ended with an error
if ($result -ne "" -and $result -ne "DONE") {
    Write-Output "<result>$result</result>"
    exit 0
}

# Sleep between polling cycles (but not on the very first call)
if ($result -ne "") {
    Start-Sleep -Seconds 30
}

Write-Output "<function return=`"RUN_FOREVER`">START</function>"
