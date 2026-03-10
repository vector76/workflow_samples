if (-not $env:RAYMOND_AGENT_ID) {
    # prevent over-zealous delete if we somehow lost the agent ID
    Write-Error "Error: RAYMOND_AGENT_ID is not set"
    exit 1
}

$featureId = (Get-Content ".bm/$($env:RAYMOND_AGENT_ID)/bm_feat_id.txt").Trim()
bm submit $featureId --description ".bm/$($env:RAYMOND_AGENT_ID)/bm_feature.md" --questions ".bm/$($env:RAYMOND_AGENT_ID)/bm_quest.md"
Remove-Item -Recurse -Force ".bm/$($env:RAYMOND_AGENT_ID)"

# forked worker terminates
Write-Output "<result>DONE</result>"
