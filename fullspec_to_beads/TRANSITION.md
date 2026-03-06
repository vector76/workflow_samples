---
allowed_transitions:
  - { tag: reset, target: EXPLORE_CODEBASE }
---
The planning phase is complete. From your conversation history, you know the name
of the plan file that was written during the DRAFT_PLAN step.

Emit a reset to begin the codebase exploration and beads generation phase, using
the actual plan filename from your conversation history as the `input` attribute.
Do not use a placeholder — use the real filename.

For example, if the plan file written earlier was `plan_myfeature.md`, emit:

<reset input="plan_myfeature.md">EXPLORE_CODEBASE</reset>

Do nothing else. This is purely a transition step.
