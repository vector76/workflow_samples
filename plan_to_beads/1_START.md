---
allowed_transitions:
  - { tag: goto, target: 2_EXPLORE_CODEBASE.md }
  - { tag: result }
---
Check if an input file was specified. The input filename should be provided below:

{{result}}

If the text above is literally the word "result" enclosed in double curly braces
(rather than an actual filename), then no input was specified. In this case, respond with:
<result>Input unspecified</result>

Otherwise, read the implementation plan from the specified file.

If the file does not exist or cannot be read, respond with:
<result>File not found: {{result}}</result>

Once you have successfully read the implementation plan, STOP. Do not take any
other actions yet — this step only reads the file. Further steps will handle
everything else.

After reading the file, respond with exactly:
<goto>2_EXPLORE_CODEBASE.md</goto>
