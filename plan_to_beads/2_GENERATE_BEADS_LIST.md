---
allowed_transitions:
  - { tag: goto, target: 3_REVIEW_FIX.md }
---
Transform the implementation plan you just read into a structured list of beads.

Each bead will be executed in a single Claude context window, so aim for beads that
represent roughly 30 minutes to 1 hour of work. Smaller, focused beads are better than
large ambitious ones — when in doubt, split.

Create a markdown file named `bead_list.md` containing:
- A list of all beads to be created
- For each bead, specify what work is included
- For each bead, include a work estimate (e.g., "~30 min", "~1 hour", "~2 hours")
- For each bead, specify its dependencies (using placeholder names initially)
- The list should be specific enough to capture scope and dependencies, but doesn't
  need full detail since the implementation plan will be available during bead creation

The format should be a simple markdown list that will later be updated with actual
bead identifiers (like bd-xk2a3) as they are created.

STOP after writing bead_list.md. Do not create any actual beads yet — that
happens in a later step.
