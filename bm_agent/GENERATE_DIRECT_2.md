---
allowed_transitions:
  - { tag: goto, target: CLEANUP, input: "{{result}}" }
---
Read the feature document `.bm/{{result}}/bm_feature.md`.

Come up with a title, and then create a bead using the syntax here:
- `bm add "title" --description "description here"` -- create a bead (see `bm add --help` for more detail)

The bead description should be the feature document verbatim.

Note the assigned bead identifier (e.g., `bd-xk2a3`) when the bead is created.

After creating the bead and getting the bead identifier, register the bead with
the backlog manager (bm).  To do so, first read `.bm/{{result}}/bm_feat_id.txt`
to get the feature ID that this bead pertains to.

Then do this command to register:
`bm register-bead <feature-id> <bead-id>`

After the bead has been registered with the above command, do this to notify
the manager that no more beads are coming:
`bm beads-done <feature-id>`

STOP after creating the bead, registering, and notifying that there are no 
other beads for this feature.  Do not begin implementation or do anything else.