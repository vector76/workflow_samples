---
allowed_transitions:
  - { tag: goto, target: 2_ANALYZE.md }
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

Once you have successfully read the feature document, STOP. Do not analyze the
codebase or write anything yet — that happens in a later step.

After reading the file, respond with exactly:
<goto>2_ANALYZE.md</goto>
