if ($env:RAYMOND_RESULT -eq "YES") {
    Write-Output "<goto>REVIEW</goto>"
} else {
    Write-Output "<goto>COMMIT</goto>"
}
