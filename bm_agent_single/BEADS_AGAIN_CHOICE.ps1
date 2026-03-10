$lower = "$($env:RAYMOND_RESULT)".ToLower()

switch ($lower) {
    "yes"   { Write-Output "<goto>REVIEW_BEADS</goto>" }
    "no"    {
                $featureId = (Get-Content "bm_feat_id.txt").Trim()
                bm register-artifact $featureId --type beads --file bm_beads.md
                Write-Output "<reset>CREATE_BEADS</reset>"
            }
    default { Write-Output "<goto>REVIEW_BEADS</goto>" }
}
