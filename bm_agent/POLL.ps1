# poll blocks forever until result is available
$result = bm poll
$action = ($result | jq -r '.action')
$featureId = ($result | jq -r '.feature_id')

if ($action -eq "dialog_step") {
    Write-Output "<goto input=`"$featureId`">DIALOG_STEP</goto>"
} elseif ($action -eq "generate") {
    Write-Output "<goto input=`"$featureId`">GENERATE</goto>"
} else {
    Write-Output "<result>Unrecognized poll result</result>"
}
