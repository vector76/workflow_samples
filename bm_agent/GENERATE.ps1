# $env:RAYMOND_RESULT contains the feature id
$result = bm fetch "$($env:RAYMOND_RESULT)"

New-Item -ItemType Directory -Force -Path ".bm/$($env:RAYMOND_AGENT_ID)" | Out-Null

($result | jq -r '.feature_description') | Set-Content ".bm/$($env:RAYMOND_AGENT_ID)/bm_feature.md"
"$($env:RAYMOND_RESULT)" | Set-Content ".bm/$($env:RAYMOND_AGENT_ID)/bm_feat_id.txt"

# transition to generating state
bm start-generate "$($env:RAYMOND_RESULT)"

Write-Output "<goto input=`"$($env:RAYMOND_AGENT_ID)`">GENERATE_DRAFT_PLAN</goto>"
