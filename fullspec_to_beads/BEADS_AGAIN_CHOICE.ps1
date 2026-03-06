$lower = "$($env:RAYMOND_RESULT)".ToLower()

switch ($lower) {
    "yes"   { Write-Output "<goto>REVIEW_BEADS</goto>" }
    "no"    { Write-Output "<goto>CREATE_BEADS</goto>" }
    default { Write-Output "<goto>REVIEW_BEADS</goto>" }
}
