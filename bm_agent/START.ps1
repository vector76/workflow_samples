if (Test-Path "STOP_REQUESTED") {
    Write-Output "<result>STOP REQUESTED</result>"
} else {
    Start-Sleep -Seconds 1
    Write-Output "<reset>CLAIM</reset>"
}
