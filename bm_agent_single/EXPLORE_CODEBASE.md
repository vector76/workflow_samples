---
allowed_transitions:
  - { tag: goto, target: REVIEW_BEADS }
---
The feature definition is in `bm_feature.md`.  The plan file to work from is 
`bm_plan.md`.  Read them to understand the feature and implementation plan. 
The beads filename (our output) is `bm_beads.md`.

The feature and plan are inputs and not to be changed, only `bm_beads.md` is to
be written.

Determine whether the plan involves modifying an existing codebase or if it's
creating a new greenfield project.

If the plan is for a greenfield project with no existing codebase to explore,
skip the exploration phase and proceed directly to generating the beads list.

If the plan involves an existing codebase, explore the specific integration
points the plan describes. Try to stay focused — explore only what the plan
actually refers to or is meaningful to the planned implementation, not the
whole codebase.

If you are discussing XML tags as part of the subject matter, use "&lt;" and
"&gt;" in place of brackets to avoid confusing the orchestrator.

Then, transform the implementation plan into a structured list of beads.

**Critical constraint — each bead runs in a completely fresh Claude Code
context window.** It has no visibility into the context of other beads and
no access to anything except files on disk.  Bead implementation has full
access to the codebase, but bead descriptions must be self-contained as far as
not referring to other beads.

Create `bm_beads.md` with two sections:

**Section 1 — Codebase Notes** (omit entirely for greenfield projects):
If you explored an existing codebase, summarize the findings here. This is a
reference used during bead creation to make descriptions precise — not a
mechanism to begin the implementation. Include:
- Integration points: specific files, functions, and classes involved
- Patterns to follow: error handling, naming, test conventions (with file references)
- Test locations: test file paths and relevant conventions

**Section 2 — Beads**:
Each bead should be a self-contained, independently executable unit of work —
roughly 45 minutes to 1.5 hours of human-equivalent work. Smaller, focused 
beads are better than large ones, so don't join unrelated functions just 
because of bead size.

Use this format for each bead:

### bead-N (placeholder): [Title]
**Work:** [Specific description — exact file paths, function names, what to do]
**Estimate:** ~X min
**Dependencies:** [bead names, or "none"]

STOP after writing the beads file. Do not create any actual beads yet — that
happens in a later step.
