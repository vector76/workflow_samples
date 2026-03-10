#  questions empty + response empty + is_final false  →  DIALOG_FIRST
#  questions empty + response empty + is_final true   →  DIALOG_FINALIZE
#  questions/response present + is_final false        →  DIALOG_NEXT
#  questions/response present + is_final true         →  DIALOG_LAST

Remove-Item -Force -ErrorAction SilentlyContinue bm_feature.md, bm_prev_quest.md, bm_user.md, bm_quest.md, bm_feat_id.txt

# $env:RAYMOND_RESULT contains the feature id
$result = bm fetch "$($env:RAYMOND_RESULT)"
($result | jq -r '.feature_description') | Set-Content "bm_feature.md"

"$($env:RAYMOND_RESULT)" | Set-Content "bm_feat_id.txt"
$questions = ($result | jq -r '.questions')
$userResponse = ($result | jq -r '.user_response')
$isFinal = ($result | jq -r '.is_final')

# questions from the previous round (if any)
if ($questions) {
    $questions | Set-Content "bm_prev_quest.md"
}

# user response from the previous round (if any)
if ($userResponse) {
    $userResponse | Set-Content "bm_user.md"
}

if (-not $questions -and -not $userResponse) {
    if ($isFinal -eq "true") {
        [System.IO.File]::WriteAllBytes("bm_quest.md", @())
        Write-Output "<goto>DIALOG_FINALIZE</goto>"
    } else {
        Write-Output "<goto>DIALOG_FIRST</goto>"
    }
} elseif ($isFinal -eq "true") {
    [System.IO.File]::WriteAllBytes("bm_quest.md", @())
    Write-Output "<goto>DIALOG_LAST</goto>"
} else {
    Write-Output "<goto>DIALOG_NEXT</goto>"
}
