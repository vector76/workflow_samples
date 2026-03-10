#  questions empty + response empty + is_final false  →  DIALOG_FIRST
#  questions empty + response empty + is_final true   →  DIALOG_FINALIZE
#  questions/response present + is_final false        →  DIALOG_NEXT
#  questions/response present + is_final true         →  DIALOG_LAST

# $env:RAYMOND_RESULT contains the feature id, $env:RAYMOND_AGENT_ID contains agent ID
$result = bm fetch "$($env:RAYMOND_RESULT)"
New-Item -ItemType Directory -Force -Path ".bm/$($env:RAYMOND_AGENT_ID)" | Out-Null
($result | jq -r '.feature_description') | Set-Content ".bm/$($env:RAYMOND_AGENT_ID)/bm_feature.md"

"$($env:RAYMOND_RESULT)" | Set-Content ".bm/$($env:RAYMOND_AGENT_ID)/bm_feat_id.txt"
$questions = ($result | jq -r '.questions')
$userResponse = ($result | jq -r '.user_response')
$isFinal = ($result | jq -r '.is_final')

# questions from the previous round (if any)
if ($questions) {
    $questions | Set-Content ".bm/$($env:RAYMOND_AGENT_ID)/bm_prev_quest.md"
}

# user response from the previous round (if any)
if ($userResponse) {
    $userResponse | Set-Content ".bm/$($env:RAYMOND_AGENT_ID)/bm_user.md"
}

if (-not $questions -and -not $userResponse) {
    if ($isFinal -eq "true") {
        Set-Content -Path ".bm/$($env:RAYMOND_AGENT_ID)/bm_quest.md" -Value "" -NoNewline
        Write-Output "<goto input=`"$($env:RAYMOND_AGENT_ID)`">DIALOG_FINALIZE</goto>"
    } else {
        Write-Output "<goto input=`"$($env:RAYMOND_AGENT_ID)`">DIALOG_FIRST</goto>"
    }
} elseif ($isFinal -eq "true") {
    Set-Content -Path ".bm/$($env:RAYMOND_AGENT_ID)/bm_quest.md" -Value "" -NoNewline
    Write-Output "<goto input=`"$($env:RAYMOND_AGENT_ID)`">DIALOG_LAST</goto>"
} else {
    Write-Output "<goto input=`"$($env:RAYMOND_AGENT_ID)`">DIALOG_NEXT</goto>"
}
