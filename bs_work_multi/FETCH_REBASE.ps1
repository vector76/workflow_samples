# FETCH_REBASE.ps1 — fetch + rebase + route by outcome
#
# Four outcomes:
#   fetch fail → <result>BAIL</result>          (network/auth failure)
#   clean      → <result>(ok)</result>          (nothing to replay)
#   merged     → <goto>RE_TEST</goto>           (rebased, verify code)
#   conflicts  → <goto>RESOLVE_CONFLICTS</goto> (needs LLM resolution)

git fetch origin *>$null
if ($LASTEXITCODE -ne 0) {
    Write-Output '<result>BAIL</result>'
    exit 0
}

$rebaseOutput = git rebase origin/main 2>&1 | ForEach-Object ToString
$exitCode = $LASTEXITCODE

if ($exitCode -ne 0) {
    Write-Output '<goto>RESOLVE_CONFLICTS</goto>'
} elseif ($rebaseOutput -match '(?i)up to date') {
    Write-Output '<result>(ok)</result>'
} else {
    Write-Output '<goto>RE_TEST</goto>'
}
