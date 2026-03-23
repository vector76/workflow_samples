
if ($env:RAYMOND_RESULT -eq "also_agent") {
    Write-Output "<fork-workflow next=""START2"">../bm_agent_702b7235241781a5269659e383e58b4f7bfbdc6976558fc88a07c151fd722123.zip</fork-workflow>"
} else {
    Write-Output '<goto>START2</goto>'
}
