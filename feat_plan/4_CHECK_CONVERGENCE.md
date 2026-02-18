---
effort: low
allowed_transitions:
  - { tag: goto, target: 3_REVIEW_FIX.md }
  - { tag: result }
---
Review the previous review/fix step and determine whether anything was actually
changed in the plan file.

If the review found and fixed meaningful issues (even minor ones), another review
pass is needed. Respond with:
<goto>3_REVIEW_FIX.md</goto>

If nothing was changed — the plan was already sound, or only observations were
noted without any fixes applied — the plan has converged and is ready. Respond
with a `<result>` tag containing the plan filename as stated at the start of
this workflow. For example, if the plan filename is `my_feature_plan.md`:
<result>my_feature_plan.md</result>
