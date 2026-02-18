---
allowed_transitions:
  - { tag: goto, target: 2_DRAFT_PLAN.md }
  - { tag: result }
---
Check if an input file was specified. The input filename should be provided below:

{{result}}

If the text above is literally the word "result" enclosed in double curly braces
(rather than an actual filename), then no input was specified. In this case,
respond with:
<result>Input unspecified</result>

Otherwise, read the feature document from the specified file.

If the file does not exist or cannot be read, respond with:
<result>File not found: {{result}}</result>

Once you have successfully read the feature document, derive the output plan
filename: take just the basename of the input file (no directory path), strip
the `.md` extension if present, and append `_plan.md`. For example:
- `my_feature.md` → `my_feature_plan.md`
- `features/auth_flow.md` → `auth_flow_plan.md`

State the plan filename clearly — it will be used throughout this workflow.

STOP after reading the file and stating the plan filename. Do not explore the
codebase or write anything yet — that happens in a later step.

After reading the file and stating the plan filename, respond with exactly:
<goto>2_DRAFT_PLAN.md</goto>
