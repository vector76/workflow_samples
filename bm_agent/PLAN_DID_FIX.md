---
model: haiku
allowed_transitions:
  - { tag: result, payload: "YES" }
  - { tag: result, payload: "NO" }
---
Review the previous review/fix step and determine whether anything was actually
changed in the plan file.

If the review found and fixed meaningful issues (even minor ones), another review
pass is needed. Respond with:
<result>YES</result>

If nothing was changed — the plan was already sound, or only observations were
noted without any fixes applied — the plan has converged. Respond with:
<result>NO</result>
