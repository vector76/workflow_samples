---
allowed_transitions:
  - { tag: call, target: VALIDATE, return: CLEANUP }
---
Now create all the beads specified in the beads file 
`.bm/{{result}}/bm_beads.md` using the `bm` command.

The relevant commands for bead creation are `bm add`, `bm link`, `bm edit`, 
`bm list`.

The relevant commands to register beads with the feature are `bm register-bead` 
to associate the bead with the feature, and `bm beads-done` to indicate no more
beads will be registered.

Details for the above commands can be found by using `--help`, for example
`bm add --help` or `bm register-bead --help`.

The `bm` command has many sub-commands so `bm --help` is only a last resort.


**Step 0: Check for partial creation**
Before starting, perform 
`bm list --status open,not_ready,in_progress`
to check for a possible aborted previous run.

Also check the `.bm/{{result}}/bm_beads.md` file for possible bead IDs.  Use
this information to determine which beads still need to be created.  Don't
create them a second time.

**Step 1: Create all beads**

For each bead in the beads file `.bm/{{result}}/bm_beads.md`:
1. Compose the bead's full description using the plan file, the bead's Work
   description, and the Codebase Notes section of the beads file (if present).
   The description is the complete prompt the bead receives — it runs in a fresh
   context with no memory of other beads. Make it self-contained: include specific
   file paths and function names so the bead can get to work immediately.
2. Create the bead using the `bm` command:
   - Create all beads with `--status not_ready` to prevent them from being 
     claimed before its prerequisites are wired up:
       `bm add --status not_ready ...`
3. Note the assigned bead identifier (e.g., bd-xk2a3)
4. Update the beads file `.bm/{{result}}/bm_beads.md` to include the assigned
   identifier next to that bead

**Step 2: Set up all dependencies**

After ALL beads have been created and you have collected all their identifiers,
set up the dependencies between beads using the `bm` command and the identifiers
from the beads file.

The `bm link` command is used to set up dependencies.  use `bm link --help` for 
details on the syntax.

**Step 3: Open the dependent beads**

After ALL dependencies have been set up, flip each `not_ready` bead to `open`:
`bm edit <id> --status open`

(This three-step sequence ensures no bead can be claimed before its 
prerequisites are fully registered, in case a worker is eager to grab open 
beads.)

**Step 4: Register all beads with backlog manager (bm)**

Read `.bm/{{result}}/bm_feat_id.txt` to get the feature ID.

Then for every bead, do this command:
`bm register-bead <feature-id> <bead-id>`

Do this for each bead whether or not they had been created previously (from 
step 0 above).

After all beads have been registered with the above command, do this to notify
the manager that no more beads are coming.
`bm beads-done <feature-id>`

STOP after completing all four steps. Do not validate yet — that happens in a
later step.
