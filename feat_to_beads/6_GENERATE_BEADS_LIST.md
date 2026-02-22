---
allowed_transitions:
  - { tag: goto, target: 7_REVIEW_BEADS.md }
---
Transform the implementation plan into a structured list of beads.

**Critical constraint — each bead runs in a completely fresh Claude Code context
window.** It has no memory of other beads and no access to anything except files on
disk. Bead descriptions must be self-contained, with specific file paths and function
names rather than vague instructions like "find the handler."

Create `bead_list.md` with two sections:

**Section 1 — Codebase Notes** (omit entirely for greenfield projects):
If you explored an existing codebase in the previous step, summarize the findings
here. This is a reference used during bead creation to make descriptions precise —
not a mechanism for beads to pass information to each other. Include:
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

STOP after writing `bead_list.md`. Do not create any actual beads yet — that
happens in a later step.

After writing the file, respond with exactly:
<goto>7_REVIEW_BEADS.md</goto>
