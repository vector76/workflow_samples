---
allowed_transitions:
  - { tag: call, target: DID_FIX, return: AGAIN_CHOICE }
---
Review the implementation with fresh eyes. Look carefully for mistakes, bugs,
unhandled edge cases, or places where there is a clearly better approach. Run
any relevant tests. Fix anything you find. There may be nothing wrong — the
point is to check.

Do not stage or commit yet — that happens in a later step.