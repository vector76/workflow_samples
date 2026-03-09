$featureId = (Get-Content "bm_feat_id.txt").Trim()
bm submit $featureId --description bm_feature.md --questions bm_quest.md
Remove-Item -Force -ErrorAction SilentlyContinue bm_feature.md, bm_prev_quest.md, bm_user.md, bm_quest.md, bm_feat_id.txt

# Write-Output "<reset>START</reset>"
Write-Output "<result>STOP</result>"
