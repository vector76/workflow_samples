---
allowed_transitions:
  - { tag: goto, target: DIALOG_FINALIZE }
---
The feature description you are working on is described in
`.bm/{{result}}/bm_feature.md`.  You're collaborating with the human to get a
good clean feature definition to then guide implementation.

Read `.bm/{{result}}/bm_feature.md`, and also read
`.bm/{{result}}/bm_prev_quest.md` (your previous questions/assumptions) and
`.bm/{{result}}/bm_user.md` (the human's response to your previous
questions/assumptions).

Update `.bm/{{result}}/bm_feature.md` file to incorporate the feedback:
- Apply corrections or overrides the human made to your assumptions
- Fold in new information or clarifications provided
- Lock in unchallenged assumptions as settled decisions in the document
- Avoid overspecifying implementation detail; keep the document focused on
  behavior and functionality

The user has said this is the last update and we're ending the dialog.
Presumably the feature is converged to a good state.  Just update the feature
document to a good final state.

STOP after updating `.bm/{{result}}/bm_feature.md`. Do not start implementation
or do anything else.  That comes later when the human decides to move forward.
