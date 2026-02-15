---
allowed_transitions:
  - { tag: goto, target: 4_CHECK_CONVERGENCE.md }
---
Review the bead_list.md file carefully by comparing it against the original
implementation plan. Look for:
- Missing beads or incomplete coverage of the implementation plan
- Incorrect or unclear dependency specifications
- Beads that are too small in scope (consider merging with a neighbor)
- Dependencies that reference non-existent beads
- Beads estimated at more than ~2 hours — these are candidates for splitting into
  smaller pieces. The sweet spot is ~30 minutes to ~1 hour per bead, since each bead
  runs in a single Claude context window. This is a soft guideline, not a hard limit;
  some beads may legitimately need more time, but prefer splitting when reasonable.
- Any other errors or opportunities for improvement

If you find major or minor issues, fix them directly in bead_list.md.

"Not a bug" observations (things that are fine as-is) do not need to be fixed,
though you may optionally improve them if clearly beneficial.

STOP after reviewing/fixing bead_list.md. Do not create any actual beads yet —
that happens in a later step.
