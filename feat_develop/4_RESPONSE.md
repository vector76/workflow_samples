---
allowed_transitions:
  - { tag: goto, target: 2_ANALYZE.md }
---
Read HUMAN_PROMPT.md. It contains the human's response to your analysis —
corrections, approvals, and answers to any items you flagged.

Then re-read and update the feature document (you have the filename from earlier
in this conversation) to incorporate the feedback:

- Apply any corrections or overrides the human made to your assumptions
- Fold in any new information or clarifications the human provided
- Incorporate your own assumptions that the human did not challenge — document
  them as settled decisions in the feature document
- Remove or rewrite any implementation detail or code that does not belong;
  keep the document focused on functionality and behavior

The goal is a feature document that clearly describes what the feature does,
with no significant gaps or ambiguities remaining.

STOP after updating the feature document. Do not re-analyze yet — that happens
in the next step.

After updating the feature document, respond with exactly:
<goto>2_ANALYZE.md</goto>
