$PromptFile = "HUMAN_PROMPT.md"
$NextState  = "4_RESPONSE.md"
$FinalState = "5_CLEANUP"

Add-Content -Path $PromptFile -Value "`n`n<!-- COMPOSING -->"

while (Select-String -Path $PromptFile -Pattern '<!-- COMPOSING -->' -Quiet -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 1
}

$content = Get-Content -Path $PromptFile -Raw -ErrorAction SilentlyContinue
if ($content -match '\S') {
    Write-Output "<goto>$NextState</goto>"
} else {
    Write-Output "<goto>$FinalState</goto>"
}
