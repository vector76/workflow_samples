---
allowed_transitions:
  - { tag: goto, target: 3_PROMPT }
---
Re-read the feature document (you have the filename from earlier in this
conversation).

Then explore the parts of the codebase that are relevant to this feature. The
codebase may be large — focus on files, modules, and patterns that are directly
related to the feature rather than reading broadly. Use grep, glob, and targeted
reads to find what is pertinent.

Based on both the feature document and your codebase exploration, evaluate the
feature document for:

- **Errors or inconsistencies**: anything that contradicts itself, conflicts with
  the existing codebase, or seems factually wrong
- **Incomplete areas**: functionality mentioned but not adequately described —
  what happens in edge cases, error conditions, or interactions with other parts
  of the system
- **Underspecified areas**: decisions left unmade — behavior that depends on
  context, user input validation, interaction with existing features, or anything
  a developer would have to guess at
- **Ambiguities**: where the description could reasonably be interpreted in more
  than one way

For each issue you identify, **make a concrete choice or assumption** rather than
asking an open-ended question. State the assumption clearly so the human can
approve or override it with minimal effort. Prefer "I assume X — correct me if
wrong" over "What should X be?". Only ask a direct question when there is
genuinely no reasonable default.

The feature document should describe **what the feature does**, not how it is
built. Code should be minimal or absent. If you spot implementation detail
creeping into the document, flag it.

Write your analysis to HUMAN_PROMPT.md, replacing the entire file contents.
Structure it clearly: lead with any significant issues, then list assumptions,
then note anything minor. If the document is already complete and well-specified
with no meaningful gaps, say so at the top and tell the human they can leave
HUMAN_PROMPT.md empty to finish the workflow.

STOP after writing HUMAN_PROMPT.md. Do not modify the feature document yet —
that happens in a later step.

After writing HUMAN_PROMPT.md, respond with exactly:
<goto>3_PROMPT</goto>
