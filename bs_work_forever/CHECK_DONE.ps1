# CHECK_DONE.ps1 — poll for work indefinitely
#
# Called when CLAIM_TASK finds nothing ready. Loops internally until
# a ready task appears — never emits a self-transition, never terminates.
#
# Polling interval: 3 minutes

$PollInterval = 180

while ($true) {
    try {
        $json = bs list --ready 2>$null | ConvertFrom-Json
        $readyBeads = $json.beads
    } catch {
        $readyBeads = @()
    }
    if ($readyBeads.Count -gt 0) {
        Write-Output '<reset>CLAIM_TASK</reset>'
        exit 0
    }
    Start-Sleep -Seconds $PollInterval
}
