---
allowed_transitions:
  - { tag: goto, target: CHECK_FIX.md }
  - { tag: goto, target: COMMIT.md }
---
Review the previous review/fix and determine whether anything was fixed, or if
everything was okay and nothing was found worthy of fixing.  If there are
"observations" that are "not a bug" then these count as not worthy of fixing.

If something major or minor was fixed, then respond with <goto>CHECK_FIX</goto>.

If nothing was fixed because everything is good, then respond with <goto>COMMIT</goto>.
Do not close the bs item yet.  It must stay as in-progress for now.
