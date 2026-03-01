$PromptFile = "HUMAN_PROMPT.md"
Remove-Item -Path $PromptFile -Force -ErrorAction SilentlyContinue
Write-Output "<result>DONE</result>"
