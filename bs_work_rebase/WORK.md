---
allowed_transitions:
  - { tag: goto, target: REVIEW }
---
Your task ID is `{{result}}`. Start by getting the full task description:

    bs show {{result}}

Then implement the task. Do not stage, commit, or review the code yet — those
happen in later steps.