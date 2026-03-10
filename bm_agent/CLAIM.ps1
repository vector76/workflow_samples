# claim blocks forever until result is available, and when it's available,
# it's exclusively allocated to us so another 'bm claim' won't return the same
# item while we're working on it
$result = bm claim
$action = ($result | jq -r '.action')
$featureId = ($result | jq -r '.feature_id')

# main thread goes back to START (and then back to CLAIM) while a fresh worker
# goes on to handle the feature
if ($action -eq "dialog_step") {
    Write-Output "<fork next=`"START`" input=`"$featureId`">DIALOG_STEP</fork>"
} elseif ($action -eq "generate") {
    Write-Output "<fork next=`"START`" input=`"$featureId`">GENERATE</fork>"
} elseif ($action -eq "timeout") {
    Write-Output "<reset>START</reset>"
} else {
    Write-Output "<reset>START</reset>"
}
