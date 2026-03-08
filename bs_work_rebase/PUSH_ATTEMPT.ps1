# PUSH_ATTEMPT.ps1 — attempt git push with retry counter
#
# Increments a counter each attempt. If over the cap, goto BAIL_OUT.
# On successful push, goto CLOSE_TASK.
# On rejection (non-fast-forward), goto REBASE.

$CounterFile = ".raymond/.push_attempts"
$MaxAttempts = 5

New-Item -ItemType Directory -Path ".raymond" -Force | Out-Null

if (Test-Path $CounterFile) {
    $count = [int](Get-Content $CounterFile)
} else {
    $count = 0
}

$count++

if ($count -gt $MaxAttempts) {
    Remove-Item -Path $CounterFile -Force -ErrorAction SilentlyContinue
    Write-Output '<goto>BAIL_OUT</goto>'
    exit 0
}

Set-Content -Path $CounterFile -Value $count

git push origin HEAD *>$null
if ($LASTEXITCODE -eq 0) {
    Remove-Item -Path $CounterFile -Force -ErrorAction SilentlyContinue
    Write-Output '<goto>CLOSE_TASK</goto>'
} else {
    Write-Output '<goto>REBASE</goto>'
}
