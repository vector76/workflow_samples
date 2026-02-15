---
allowed_transitions:
  - { tag: goto, target: 4_CHECK_CONVERGENCE.md }
---
Review the bead_list.md file carefully by comparing it against the original
implementation plan. Look for:
- Missing beads or incomplete coverage of the implementation plan
- Incorrect or unclear dependency specifications
- Beads that are too large or too small in scope
- Dependencies that reference non-existent beads
- Any other errors or opportunities for improvement

If you find major or minor issues, fix them directly in bead_list.md.

"Not a bug" observations (things that are fine as-is) do not need to be fixed,
though you may optionally improve them if clearly beneficial.

STOP after reviewing/fixing bead_list.md. Do not create any actual beads yet —
that happens in a later step.
