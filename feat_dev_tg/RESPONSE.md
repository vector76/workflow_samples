---
allowed_transitions:
  - { tag: goto, target: PROMPT }
---
You know the in_progress filename from earlier in this conversation.

Read the in_progress file. Read `HUMAN_PROMPT.md` (your previous analysis) and
`HUMAN_RESPONSE.md` (the human's response).

Update the in_progress file to incorporate the feedback:
- Apply corrections or overrides the human made to your assumptions
- Fold in new information or clarifications provided
- Lock in unchallenged assumptions as settled decisions in the document
- Remove or rewrite any implementation detail; keep the document focused on
  behavior and functionality

Delete `HUMAN_PROMPT.md` and `HUMAN_RESPONSE.md`.

Then re-analyze the updated in_progress file for any remaining gaps, ambiguities, or
new questions raised by the human's response. Write your updated analysis to
`HUMAN_PROMPT.md`. If the document is now complete and well-specified, say so
and tell the human they can reply with just the word "done" to finish.
Remind the human that if they have one last round of feedback but want to
finish after it, they can end their reply with "done" on its own line.

STOP after writing HUMAN_PROMPT.md. Do not wait for a response yet — that
happens in a later step.

After writing HUMAN_PROMPT.md, respond with exactly:
<goto>PROMPT</goto>
