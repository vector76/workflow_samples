
if ($env:RAYMOND_RESULT -eq "also_agent") {
    Write-Output "<fork-workflow next=""START2"">../bm_agent/</fork-workflow>"
} else {
    Write-Output '<goto>START2</goto>'
}
