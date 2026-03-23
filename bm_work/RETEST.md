---
allowed_transitions:
  - { tag: goto, target: PUSH_ATTEMPT }
  - { tag: goto, target: REWORK }
---
A rebase has just completed, incorporating upstream changes into our work.
The rebase may have introduced subtle incompatibilities even if there were
no textual conflicts.

Run the project's test suite to verify that everything still works correctly.

If all tests pass, respond with `<goto>PUSH_ATTEMPT</goto>`.

If tests fail, respond with `<goto>REWORK</goto>`.
