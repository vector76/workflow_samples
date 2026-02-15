---
allowed_transitions:
  - { tag: goto, target: 2_GENERATE_BEADS_LIST.md }
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

Once you have successfully read the implementation plan, proceed to the next step
with:
<goto>2_GENERATE_BEADS_LIST.md</goto>
