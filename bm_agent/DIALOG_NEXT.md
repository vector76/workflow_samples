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

Then re-analyze the updated `.bm/{{result}}/bm_feature.md` file for any
remaining gaps, ambiguities, or new questions raised by the human's response.
Write your updated analysis to `.bm/{{result}}/bm_quest.md`. If the document is
now complete and well-specified, say so.

STOP after writing `.bm/{{result}}/bm_quest.md`. Do not start implementation or
do anything else.  That comes later after the human reviews your feedback.
