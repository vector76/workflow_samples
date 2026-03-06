---
allowed_transitions:
  - { tag: goto, target: REVIEW_BEADS.md }
---
The plan file to work from is:

{{result}}

Read `{{result}}` to understand the implementation plan. Derive the beads filename
from the plan filename by replacing the `plan_` prefix with `beads_` — for example,
`plan_myfeature.md` becomes `beads_myfeature.md`.

Determine whether the plan involves modifying an **existing codebase**. Signs include:
- References to specific existing files, modules, functions, or classes
- Instructions to integrate into or extend existing functionality
- Mentions of existing tests, patterns, or conventions to follow

**If the plan is for a greenfield project** with no existing codebase to explore,
skip the exploration phase and proceed directly to generating the beads list.

**If the plan involves an existing codebase**, explore the specific integration points
the plan describes. Stay focused — explore only what the plan actually refers to, not
the whole codebase.

For each area the plan mentions, identify:
- The exact files involved (with paths)
- The specific functions, classes, or methods that are the integration points
- Existing conventions to follow (error handling, test structure, naming patterns)
- Precisely where new code will be inserted or what will be changed

If you are discussing XML tags as part of the subject matter, use "&lt;" and "&gt;"
in place of brackets to avoid confusing the orchestrator.

Then, transform the implementation plan into a structured list of beads.

**Critical constraint — each bead runs in a completely fresh Claude Code context
window.** It has no memory of other beads and no access to anything except files on
disk. Bead descriptions must be self-contained, with specific file paths and function
names rather than vague instructions like "find the handler."

Create `beads_<name>.md` (using the actual derived filename) with two sections:

**Section 1 — Codebase Notes** (omit entirely for greenfield projects):
If you explored an existing codebase, summarize the findings here. This is a
reference used during bead creation to make descriptions precise — not a mechanism
for beads to pass information to each other. Include:
- Integration points: specific files, functions, and classes involved
- Patterns to follow: error handling, naming, test conventions (with file references)
- Test locations: test file paths and relevant conventions

**Section 2 — Beads**:
Each bead should be a self-contained, independently executable unit of work —
roughly 30 minutes to 1 hour. Smaller, focused beads are better than large ones;
when in doubt, split. Aim for beads that can be attempted without needing structured
output from a predecessor beyond what naturally exists in the project files.

Use this format for each bead:

### bead-N (placeholder): [Title]
**Work:** [Specific description — exact file paths, function names, what to do]
**Estimate:** ~X min
**Dependencies:** [bead names, or "none"]

STOP after writing the beads file. Do not create any actual beads yet — that
happens in a later step.
