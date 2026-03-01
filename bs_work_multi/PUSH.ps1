# PUSH.ps1 — check call result + push or route
#
# Receives RAYMOND_RESULT from the call branch and routes:
#   (ok)    → try git push; success → CLOSE_TASK, rejected → PUSH_GATE.ps1
#   REWORK  → delete counter, goto RUN_TESTS (re-enter review loop)
#   BAIL    → goto BAIL_OUT (abandon work)

$CounterFile = ".raymond/.push_attempts"

switch ($env:RAYMOND_RESULT) {
    "(ok)" {
        git push origin HEAD *>$null
        if ($LASTEXITCODE -eq 0) {
            Remove-Item -Path $CounterFile -Force -ErrorAction SilentlyContinue
            Write-Output '<goto>CLOSE_TASK</goto>'
        } else {
            Write-Output '<goto>PUSH_GATE.ps1</goto>'
        }
    }
    "REWORK" {
        Remove-Item -Path $CounterFile -Force -ErrorAction SilentlyContinue
        Write-Output '<goto>RUN_TESTS</goto>'
    }
    "BAIL" {
        Write-Output '<goto>BAIL_OUT</goto>'
    }
    default {
        Write-Output '<goto>BAIL_OUT</goto>'
    }
}
