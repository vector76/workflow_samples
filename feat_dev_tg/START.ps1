$underspecFiles = Get-ChildItem -Path . -Filter "underspec_*.md" -File

foreach ($file in $underspecFiles) {
    $name = $file.Name -replace '^underspec_', ''
    $inProgress = "in_progress_$name"
    $fullspec = "fullspec_$name"
    if (-not (Test-Path $inProgress) -and -not (Test-Path $fullspec)) {
        Copy-Item $file.FullName $inProgress
        Write-Output "<function return=`"DONE`" input=`"$inProgress`">ANALYZE</function>"
        exit 0
    }
}

Write-Output "<result>DONE</result>"
