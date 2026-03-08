# REBASE.ps1 — fetch and rebase onto the current branch's remote head
#
# Outcomes:
#   fetch fail  → <goto>BAIL_OUT</goto>   (network/auth failure)
#   clean       → <goto>RETEST</goto>     (rebased cleanly, verify code)
#   conflicts   → <goto>RESOLVE</goto>    (needs conflict resolution)

$branch = git rev-parse --abbrev-ref HEAD

git fetch origin *>$null
if ($LASTEXITCODE -ne 0) {
    Write-Output '<goto>BAIL_OUT</goto>'
    exit 0
}

git rebase "origin/$branch" *>$null
if ($LASTEXITCODE -ne 0) {
    Write-Output '<goto>RESOLVE</goto>'
} else {
    Write-Output '<goto>RETEST</goto>'
}
