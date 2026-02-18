---
allowed_transitions:
  - { tag: goto, target: 5_CHECK_CONVERGENCE.md }
---
Review bead_list.md carefully against the original implementation plan. Look for:

**Coverage and structure:**
- Missing beads or incomplete coverage of the implementation plan
- Incorrect or unclear dependency specifications
- Beads that are too small in scope (consider merging with a neighbor)
- Dependencies that reference non-existent beads
- Beads estimated at more than ~2 hours — candidates for splitting. Sweet spot is
  ~30 min to ~1 hour per bead. Soft guideline, not a hard limit.

**Fresh-context and independence:**
- Vague Work descriptions that say "find the handler" or "locate the relevant code"
  when specific file paths and function names are available in the Codebase Notes
  section or derivable from the plan. Bead descriptions should be specific enough
  that the bead can get to work immediately without re-doing the exploration.
- "Research beads" that exist solely to gather information for later beads. This is
  a bad pattern — beads run in a fresh context and cannot reliably pass structured
  findings to one another. Research should happen during the plan_to_beads process
  and be baked into the relevant bead descriptions or the Codebase Notes section.
  If a research bead appears, fold its findings into the descriptions of the beads
  that need them (or into Codebase Notes), then remove it.
- Unnecessarily sequential dependencies. Dependencies should reflect genuine ordering
  constraints (e.g., implement before testing), not information transfer between beads.

If you find major or minor issues, fix them directly in bead_list.md.

"Not a bug" observations do not need to be fixed, though you may improve them if
clearly beneficial.

STOP after reviewing/fixing bead_list.md. Do not create any actual beads yet —
that happens in a later step.

After completing your review, respond with exactly:
<goto>5_CHECK_CONVERGENCE.md</goto>
