---
allowed_transitions:
  - { tag: goto, target: CHECK_FIX.md }
---
A rebase introduced issues that need to be fixed.  Run the project's test
suite now so that the results are available for the review step.

After the tests complete (whether they pass or fail), respond with
"<goto>CHECK_FIX</goto>" to proceed to the review/fix cycle.
