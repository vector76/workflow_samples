---
allowed_transitions:
  - { tag: goto, target: 2_CHECK_WRAP }
---
Look for files named TASK<number>.md and select the lowest number (or simply 
TASK.md) for the task to be done.  Read that file and ignore all the other 
tasks.

Note that the given task described in that file may be in progress, so start 
with research to determine the current state before changing anything.  Then 
begin (or continue) work on that task.

Once you finish the implementation, *STOP*.  Do not stage or commit yet.  I 
need to review the code before proceeding further.