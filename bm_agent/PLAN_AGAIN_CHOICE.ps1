$lower = "$($env:RAYMOND_RESULT)".ToLower()

switch ($lower) {
    "yes"   { Write-Output "<goto>REVIEW_PLAN</goto>" }
    "no"    {
                $featureId = (Get-Content "bm_feat_id.txt").Trim()
                bm register-artifact $featureId --type plan --file bm_plan.md
                Write-Output "<reset>EXPLORE_CODEBASE</reset>"
            }
    default { Write-Output "<goto>REVIEW_PLAN</goto>" }
}
