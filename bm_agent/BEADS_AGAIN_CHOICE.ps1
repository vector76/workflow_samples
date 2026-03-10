$lower = "$($env:RAYMOND_RESULT)".ToLower()

switch ($lower) {
    "yes"   { Write-Output "<goto input=`"$($env:RAYMOND_AGENT_ID)`">REVIEW_BEADS</goto>" }
    "no"    {
                $featureId = (Get-Content ".bm/$($env:RAYMOND_AGENT_ID)/bm_feat_id.txt").Trim()
                bm register-artifact $featureId --type beads --file ".bm/$($env:RAYMOND_AGENT_ID)/bm_beads.md"
                Write-Output "<reset input=`"$($env:RAYMOND_AGENT_ID)`">CREATE_BEADS</reset>"
            }
    default { Write-Output "<goto input=`"$($env:RAYMOND_AGENT_ID)`">REVIEW_BEADS</goto>" }
}
