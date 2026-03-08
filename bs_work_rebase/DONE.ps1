if ($env:RAYMOND_RESULT -eq "GOOD" -or $env:RAYMOND_RESULT -eq "BAIL_OUT") {
    Write-Output "<reset>CLAIM</reset>"
} else {
    Write-Output "<result>$($env:RAYMOND_RESULT)</result>"
}
