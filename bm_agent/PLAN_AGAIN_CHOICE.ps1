$lower = "$($env:RAYMOND_RESULT)".ToLower()

switch ($lower) {
    "yes"   { Write-Output "<goto input=`"$($env:RAYMOND_AGENT_ID)`">REVIEW_PLAN</goto>" }
    "no"    {
                $featureId = (Get-Content ".bm/$($env:RAYMOND_AGENT_ID)/bm_feat_id.txt").Trim()
                bm register-artifact $featureId --type plan --file ".bm/$($env:RAYMOND_AGENT_ID)/bm_plan.md"
                Write-Output "<reset input=`"$($env:RAYMOND_AGENT_ID)`">EXPLORE_CODEBASE</reset>"
            }
    default { Write-Output "<goto input=`"$($env:RAYMOND_AGENT_ID)`">REVIEW_PLAN</goto>" }
}
