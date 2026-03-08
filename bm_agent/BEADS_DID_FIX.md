---
model: haiku
allowed_transitions:
  - { tag: result, payload: "YES" }
  - { tag: result, payload: "NO" }
---
Review the previous review/fix step and determine whether anything was actually
fixed in the beads file.

If major or minor issues were identified and fixed, then another review cycle is
needed. Respond with:
<result>YES</result>

If nothing was fixed (either because everything was already correct, or only
"not a bug" observations were made without applying fixes), then the beads list
has converged. Respond with:
<result>NO</result>
