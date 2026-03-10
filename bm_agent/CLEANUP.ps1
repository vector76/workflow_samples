if (-not $env:RAYMOND_AGENT_ID) {
    # prevent over-zealous delete if we somehow lost the agent ID
    Write-Error "Error: RAYMOND_AGENT_ID is not set"
    exit 1
}

Remove-Item -Recurse -Force ".bm/$($env:RAYMOND_AGENT_ID)"

# forked worker terminates
Write-Output "<result>$($env:RAYMOND_RESULT)</result>"
