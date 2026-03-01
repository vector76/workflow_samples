# PUSH_GATE.ps1 — counter check + call into push attempt
#
# Reads/increments a retry counter. If under the cap, calls FETCH_REBASE.ps1
# with return to PUSH.ps1 (isolating each push attempt in its own session).
# If over the cap, transitions to BAIL_OUT.

$CounterFile = ".raymond/.push_attempts"
$MaxAttempts = 5

New-Item -ItemType Directory -Path ".raymond" -Force | Out-Null

if (Test-Path $CounterFile) {
    $count = [int](Get-Content $CounterFile)
} else {
    $count = 0
}

$count++

if ($count -le $MaxAttempts) {
    Set-Content -Path $CounterFile -Value $count
    Write-Output '<call return="PUSH.ps1">FETCH_REBASE.ps1</call>'
} else {
    Remove-Item -Path $CounterFile -Force -ErrorAction SilentlyContinue
    Write-Output '<goto>BAIL_OUT</goto>'
}
