if ($env:RAYMOND_RESULT -eq "GOOD") {
    Write-Output "<reset>CLAIM</reset>"
} else {
    Write-Output "<result>$($env:RAYMOND_RESULT)</result>"
}
