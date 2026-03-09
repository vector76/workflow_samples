# $env:RAYMOND_RESULT contains the feature id
$result = bm fetch "$($env:RAYMOND_RESULT)"
($result | jq -r '.feature_description') | Set-Content "bm_feature.md"
"$($env:RAYMOND_RESULT)" | Set-Content "bm_feat_id.txt"

# transition to generating state
bm start-generate "$($env:RAYMOND_RESULT)"

Write-Output "<goto>GENERATE_DRAFT_PLAN</goto>"
