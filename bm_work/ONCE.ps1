$null = bm list 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Output "<goto>CLAIM</goto>"
} else {
    Start-Sleep -Seconds 10
    Write-Output "<result>NOT CONFIGURED</result>"
}
