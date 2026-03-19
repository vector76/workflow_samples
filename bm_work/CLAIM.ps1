
# Check for an existing in-progress task from a previous run
$mineJson = bm mine 2>&1
$mineData = $mineJson | ConvertFrom-Json -ErrorAction SilentlyContinue
$taskId = $mineData.beads | Select-Object -First 1 -ExpandProperty id -ErrorAction SilentlyContinue

if ($taskId) {
    Write-Output "<function return=`"DONE`" input=`"$taskId`">WORK</function>"
    exit 0
}

# No in-progress task — try to claim one
$readyJson = bm list --ready 2>&1
$readyData = $readyJson | ConvertFrom-Json -ErrorAction SilentlyContinue
$taskId = $readyData.beads | Select-Object -First 1 -ExpandProperty id -ErrorAction SilentlyContinue

if (-not $taskId) {
    Write-Output "<result>DONE</result>"
    exit 0
}

$null = bm claim $taskId 2>&1
if ($LASTEXITCODE -eq 0) {
    git pull
    Write-Output "<function return=`"DONE`" input=`"$taskId`">WORK</function>"
    exit 0
}

Write-Output "<result>CLAIM FAILED</result>"
