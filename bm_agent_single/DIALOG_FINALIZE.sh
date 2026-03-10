#!/bin/bash

feature_id=$(cat bm_feat_id.txt)
bm submit "$feature_id" --description bm_feature.md --questions bm_quest.md
rm -f bm_feature.md bm_prev_quest.md bm_user.md bm_quest.md bm_feat_id.txt

# echo "<reset>START</reset>"
echo "<result>STOP</result>"
