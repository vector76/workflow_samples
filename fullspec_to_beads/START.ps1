# Look for a fullspec_<name>.md file where there is no plan_<name>.md or beads_<name>.md

$eligible = $null
foreach ($file in Get-ChildItem -Filter "fullspec_*.md") {
    $name = $file.Name -replace '^fullspec_', '' -replace '\.md$', ''
    if (-not (Test-Path "plan_$name.md") -and -not (Test-Path "beads_$name.md")) {
        $eligible = $file.Name
        break
    }
}

if (-not $eligible) {
    Write-Output "<result>DONE</result>"
} else {
    Write-Output "<function return=`"DONE`" input=`"$eligible`">DRAFT_PLAN</function>"
}
