---
allowed_transitions:
  - { tag: result }
---
A rebase has just been completed, incorporating upstream changes into our
work.  The rebase may have introduced subtle incompatibilities even if
there were no textual conflicts.

Run the project's test suite to verify that everything still works correctly.

If all tests pass, respond with "<result>(ok)</result>".

If tests fail, respond with "<result>REWORK</result>".
