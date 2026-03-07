
With START as entry point (default):

START  check bs setup before proceeding
CLAIM  function call to WORK with return to DONE
  WORK
  REVIEW  call to DID_FIX with return to AGAIN_CHOICE
    DID_FIX  result YES or NO (returns to AGAIN_CHOICE)
  AGAIN_CHOICE  goto REVIEW or goto COMMIT
  COMMIT  result GOOD or return PROBLEM (returns to DONE)
DONE  reset to CLAIM or result


With RUN_FOREVER as entry point (unlimited alternative)

RUN_FOREVER  function call to START with return to OUTER_LOOP
  START  check bs setup before proceeding
  CLAIM  function call to WORK with return to DONE
    WORK
    REVIEW  call to DID_FIX with return to AGAIN_CHOICE
      DID_FIX  result YES or NO (returns to AGAIN_CHOICE)
    AGAIN_CHOICE  goto REVIEW or goto COMMIT
    COMMIT  result GOOD or return PROBLEM (returns to DONE)
  DONE  reset to CLAIM or result
OUTER_LOOP  (states CLAIM or DONE may return here)  reset to RUN_FOREVER


**START.sh**
Run `bs list` — if it produces an error "BS_TOKEN is required" or if it can't 
talk to the server, then `<result>NOT CONFIGURED</result>`
Otherwise `<goto>CLAIM</goto>`.

**CLAIM.sh**
Run `bs mine`.  If there is a task that's already mine, then that's our task.
Transition via `function` to WORK, with return to DONE and with input=task id.

If we don't already have a task, then do `bs list --ready` to get a list.
If the list is empty, then `<result>DONE</result>`

If the list is not empty, then claim an item with `bs claim <id>`, and if 
successful, that's our task.  If unsuccessful, get the list again and try 
again, up to three times.  If it fails three times, then 
`<result>CLAIM FAILED</result>`

**WORK**
The task id is `{{result}}`.  Then get its full description with `bs show <id>`.

Do the implementation.  Don't stage or commit.

`<goto>REVIEW</goto>`

**REVIEW**
Check again with fresh eyes.

`<call return="AGAIN_CHOICE">DID_FIX</call>`

**DID_FIX**
If the previous check fixed anything, respond `YES`, otherwise respond `NO`.

**AGAIN_CHOICE.sh**
If the input is `YES` then `<goto>REVIEW</goto>`
If the input is `NO` then `<goto>COMMIT</goto>`

**COMMIT**
If there was a problem that couldn't be resolved, then don't commit, leave 
dirty and return with `<result>PROBLEM</result>`

If the system is clean, then stage, commit, and push.  Then mark item complete.
Then return `<result>GOOD</result>`

Commit message conventions:
- Do not mention Claude as a coauthor or contributor
- Add "Built with Raymond (Agent Orchestrator)" at the end of the commit message

**DONE.sh**
If result is good, `<reset>CLAIM</reset>`
If result is anything else `<result>{{result}}</result>`
