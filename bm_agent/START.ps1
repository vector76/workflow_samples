if (Test-Path "STOP_REQUESTED") {
    Write-Output "<result>STOP REQUESTED</result>"
} else {
    Write-Output "<reset>CLAIM</reset>"
}
