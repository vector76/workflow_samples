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

Otherwise, before reading anything, check for files that would be overwritten:

1. Check whether `plan.md` exists in the current directory. If it does, respond with:
   <result>Aborted: plan.md already exists</result>

2. Check whether `bead_list.md` exists in the current directory. If it does, respond with:
   <result>Aborted: bead_list.md already exists</result>

3. Read the feature document from the specified file. If the file does not exist
   or cannot be read, respond with:
   <result>File not found: {{result}}</result>

If all checks pass, state clearly that you have read the feature document and that
the plan will be written to `plan.md`.

STOP after reading the file and making this confirmation. Do not explore the
codebase or write anything yet — that happens in a later step.

After reading the file and making this confirmation, respond with exactly:
<goto>2_DRAFT_PLAN.md</goto>
