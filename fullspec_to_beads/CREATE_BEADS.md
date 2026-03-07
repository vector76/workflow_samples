---
allowed_transitions:
  - { tag: goto, target: VALIDATE.md }
---
Now create all the beads specified in the beads file using the `bs` command.

**Step 1: Create all beads**

For each bead in the beads file:
1. Compose the bead's full description using the plan file, the bead's Work
   description, and the Codebase Notes section of the beads file (if present).
   The description is the complete prompt the bead receives — it runs in a fresh
   context with no memory of other beads. Make it self-contained: include specific
   file paths and function names so the bead can get to work immediately.
2. Create the bead using the `bs` command:
   - If the bead has **no dependencies**: create it normally (open by default)
   - If the bead **has dependencies**: create it with `--status not_ready` to
     prevent it from being claimed before its prerequisites are wired up:
     `bs add --status not_ready ...`
3. Note the assigned bead identifier (e.g., bd-xk2a3)
4. Update the beads file to include the assigned identifier next to that bead

**Step 2: Set up all dependencies**

After ALL beads have been created and you have collected all their identifiers,
set up the dependencies between beads using the `bs` command and the identifiers
from the beads file.

The `bs link` command is used to set up dependencies.  use `bs link --help` for 
details on the syntax.

**Step 3: Open the dependent beads**

After ALL dependencies have been set up, flip each `not_ready` bead to `open`:
`bs edit <id> --status open`

This three-step sequence ensures no bead can be claimed before its prerequisites
are fully registered.

STOP after completing all three steps. Do not validate yet — that happens in a
later step.
