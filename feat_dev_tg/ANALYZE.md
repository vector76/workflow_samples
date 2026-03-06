---
allowed_transitions:
  - { tag: goto, target: PROMPT }
---
The in_progress filename you are working on is: {{result}}

Read that file now.

Analyze the in_progress document for:

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

The feature document should describe **what** the feature does, not how it is
built. Flag any implementation detail creeping into the document.

Write your analysis to `HUMAN_PROMPT.md`, replacing the entire file. Lead with
significant issues, then list assumptions, then minor notes. If the document is
already complete and well-specified with no meaningful gaps, say so at the top
and tell the human they can reply with just the word "done" to finish the
workflow. In all cases, remind the human that if they have one last round of
feedback but want to finish after it, they can end their reply with "done" on
its own line.

STOP after writing HUMAN_PROMPT.md. Do not modify the in_progress file yet — that
happens in a later step.

After writing HUMAN_PROMPT.md, respond with exactly:
<goto>PROMPT</goto>
