---
allowed_transitions:
  - { tag: goto, target: DIALOG_FINALIZE }
---
The feature description you are working on is described in `bm_feature.md` (in 
the project root).  Read that file now.  You're collaborating with the human to
get a good clean feature definition to then guide implementation.

Analyze the feature document for:
- **Errors or inconsistencies**: anything that contradicts itself or conflicts
  with how software typically works
- **Incomplete areas**: functionality mentioned but not adequately described —
  edge cases, error conditions, interactions with other parts of the system
- **Underspecified areas**: decisions left unmade — behavior that a developer
  would have to guess at
- **Ambiguities**: descriptions that could reasonably be interpreted in more
  than one way

For each issue, **make a concrete assumption** rather than asking an open-ended
question. State the assumption clearly so the human can approve or override with
minimal effort. Use "I assume X — correct me if wrong" rather than "What should
X be?". Only ask a direct question when there is genuinely no reasonable default.

Update the feature document with your corrections/assumptions.

The feature document should describe **what** the feature does, not how it is
built. A little bit of mention of implementation detail is okay but don't be
over-specifying the implementation.  The implementer is smart and can figure it
out.

Write your questions/assumptions to `bm_quest.md` (in the project root), 
replacing the entire file if it exists. Lead with significant issues, then 
list assumptions, then minor notes. If the document is already complete and 
well-specified with no meaningful gaps, say so at the top.

STOP after writing `bm_quest.md`. Do not start implementation or do anything 
else.  That comes later after the human reviews your feedback.
