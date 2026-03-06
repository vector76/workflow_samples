$lower = "$($env:RAYMOND_RESULT)".ToLower()

switch ($lower) {
    "yes"   { Write-Output "<goto>REVIEW_PLAN</goto>" }
    "no"    { Write-Output "<goto>TRANSITION</goto>" }
    default { Write-Output "<goto>REVIEW_PLAN</goto>" }
}
