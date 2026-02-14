---
model: sonnet
allowed_transitions:
  - { tag: result }
---
Review the previous review/fix and determine whether anything was fixed, or 
if everything was okay and nothing was found worthy of fixing.  If there are 
"observations" that are "not a bug" then these count as not worthy of fixing.

If something major or minor was fixed, then respond with 
<result>SOMETHING FIXED</result>.

If nothing was fixed because everything is good, then respond with 
<result>DONE</result>.