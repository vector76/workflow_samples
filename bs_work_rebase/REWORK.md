---
allowed_transitions:
  - { tag: goto, target: COMMIT.md }
  - { tag: goto, target: BAIL_OUT.sh }
---
Tests are failing after a rebase.  Diagnose and fix the failures.  The
problem may be an incompatibility between the upstream changes and our
implementation.

Do not stage or commit — that is handled by COMMIT.

If you are able to fix the failures, respond with `<goto>COMMIT</goto>`.

If the failures cannot be resolved (too complex, contradictory requirements,
or repeated unsuccessful attempts), respond with `<goto>BAIL_OUT</goto>`
to abandon this task and release it for another agent.
