---
allowed_transitions:
  - { tag: goto, target: 6_GENERATE_BEADS_LIST.md }
---
Read `plan.md`.

Determine whether the plan involves modifying an **existing codebase**. Signs include:
- References to specific existing files, modules, functions, or classes
- Instructions to integrate into or extend existing functionality
- Mentions of existing tests, patterns, or conventions to follow

**If the plan is for a greenfield project** with no existing codebase to explore,
your work for this step is done. STOP.

**If the plan involves an existing codebase**, explore the specific integration points
the plan describes. Stay focused — explore only what the plan actually refers to, not
the whole codebase.

For each area the plan mentions, identify:
- The exact files involved (with paths)
- The specific functions, classes, or methods that are the integration points
- Existing conventions to follow (error handling, test structure, naming patterns)
- Precisely where new code will be inserted or what will be changed

If you are discussing XML tags, as part of the subject matter, use "&lt;" and "&gt;" 
in place of brackets to avoid confusing the orchestrator, which is going to be 
scanning your output.

STOP after exploring. Your findings will be incorporated into `bead_list.md` in the
next step.
