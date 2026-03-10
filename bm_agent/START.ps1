# later might change this to a function call with a return that loops.  For now
# handles only one event.
#Write-Output "<goto>POLL</goto>"
if (Test-Path "STOP_REQUESTED") {
    Write-Output "<result>STOP REQUESTED</result>"
} else {
    Write-Output "<function return=`"OUTER_LOOP`">POLL</function>"
}
