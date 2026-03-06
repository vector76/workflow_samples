---
allowed_transitions:
  - { tag: goto, target: CLEANUP }
---
You know the in_progress filename from earlier in this conversation.

Read the in_progress file. Read `HUMAN_PROMPT.md` (your previous analysis) and
`HUMAN_RESPONSE.md` (the human's final response).

Update the in_progress file to incorporate the human's final feedback:
- Apply any corrections or overrides
- Fold in any new information provided
- Lock in all unchallenged assumptions as settled decisions
- Remove any implementation details; keep the document focused on behavior

Delete `HUMAN_PROMPT.md` and `HUMAN_RESPONSE.md`.

STOP after updating the in_progress file and deleting the files. Do not analyze further
or write a new prompt — the workflow is finishing.

After completing, respond with exactly:
<goto>CLEANUP</goto>
