tgask ask -t -f HUMAN_PROMPT.md -o HUMAN_RESPONSE.md

if (-not (Test-Path "HUMAN_RESPONSE.md")) {
    Write-Output "<goto>CLEANUP</goto>"
    exit 0
}

$content = Get-Content -Path "HUMAN_RESPONSE.md" -Raw -ErrorAction SilentlyContinue
$trimmed = $content.Trim()
$lastLine = ($content -split "`n" | Where-Object { $_ -match '\S' } | Select-Object -Last 1).Trim()

if ($trimmed -eq "done") {
    Remove-Item -Force "HUMAN_PROMPT.md", "HUMAN_RESPONSE.md" -ErrorAction SilentlyContinue
    Write-Output "<goto>CLEANUP</goto>"
} elseif ($lastLine -eq "done") {
    # Strip the trailing "done" line so downstream receives clean content.
    $lines = Get-Content "HUMAN_RESPONSE.md"
    for ($i = $lines.Length - 1; $i -ge 0; $i--) {
        if ($lines[$i] -match '\S') {
            $newLines = for ($j = 0; $j -lt $lines.Length; $j++) { if ($j -ne $i) { $lines[$j] } }
            $newLines | Set-Content "HUMAN_RESPONSE.md"
            break
        }
    }
    Write-Output "<goto>FINAL_RESPONSE</goto>"
} else {
    Write-Output "<goto>RESPONSE</goto>"
}
