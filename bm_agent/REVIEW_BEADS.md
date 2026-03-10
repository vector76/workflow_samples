---
allowed_transitions:
  - { tag: call, target: BEADS_DID_FIX, return: BEADS_AGAIN_CHOICE }
---
Re-read the beads file `.bm/{{result}}/bm_beads.md` carefully against the plan
file `.bm/{{result}}/bm_plan.md`. Look for:

**Coverage and structure:**
- Missing beads or incomplete coverage of the implementation plan
- Incorrect or unclear dependency specifications
- Beads that are too small in scope (consider merging with a neighbor)
- Dependencies that reference non-existent beads
- Beads estimated at more than ~2 hours — candidates for splitting. Sweet spot
  is ~45 min to ~1.5 hours per bead. Soft guideline, not a hard limit.

**Fresh-context and independence:**
- Vague Work descriptions that say "find the handler" or "locate the relevant
  code" when specific file paths and function names are available in the
  Codebase Notes section or derivable from the plan. Bead descriptions should
  be specific enough that the bead can get to work immediately without re-doing
  the exploration.
- "Research beads" that exist solely to gather information for later beads. 
  This is a bad pattern — beads run in a fresh context and cannot reliably pass
  structured findings to one another. Research should happen during the 
  plan-to-beads process and be baked into the relevant bead descriptions or the
  Codebase Notes section.
- Unnecessarily sequential dependencies. Dependencies should reflect genuine
  ordering constraints (e.g., implement before testing), not information
  transfer between beads.

If you find major or minor issues, fix them directly in the beads file.

"Not a bug" observations do not need to be fixed, though you may improve them if
clearly beneficial.

STOP after reviewing/fixing the beads file. Do not create any actual beads yet —
that happens in a later step.
