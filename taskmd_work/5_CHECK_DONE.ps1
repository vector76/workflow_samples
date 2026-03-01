if (-not $env:RAYMOND_RESULT) {
    Write-Output '<goto>2_CHECK_WRAP</goto>'
} elseif ($env:RAYMOND_RESULT -eq 'DONE') {
    Write-Output '<goto>6_COMMIT.md</goto>'
} else {
    Write-Output '<goto>2_CHECK_WRAP</goto>'
}
