# CHECK_DONE.ps1 — poll for work or terminate
#
# Called when CLAIM_TASK finds nothing ready. Polls periodically:
#   1. Check bs list --ready — if any ready, reset to CLAIM_TASK
#   2. Check bs list --status open — if any open (possibly blocked), sleep and retry
#   3. Nothing open — all work is closed or in-progress, terminate
#
# Polling interval: 3 minutes

$PollInterval = 180

# Check if any tasks are ready to claim right now
try {
    $json = bs list --ready 2>$null | ConvertFrom-Json
    $readyBeads = $json.beads
} catch { $readyBeads = @() }

if ($readyBeads.Count -gt 0) {
    Write-Output '<reset>CLAIM_TASK</reset>'
    exit 0
}

# Check if any tasks are open (including blocked)
try {
    $json = bs list --status open 2>$null | ConvertFrom-Json
    $openBeads = $json.beads
} catch { $openBeads = @() }

if ($openBeads.Count -gt 0) {
    # Open tasks exist but none are ready — they may become unblocked
    # when other agents complete their work. Wait and check again.
    Start-Sleep -Seconds $PollInterval
    Write-Output '<goto>CHECK_DONE.ps1</goto>'
    exit 0
}

# Nothing open — all tasks are either closed or in-progress.
# This worker is surplus. Terminate.
Write-Output '<result>DONE</result>'
