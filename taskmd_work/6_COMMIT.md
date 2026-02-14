---
model: sonnet
allowed_transitions:
  - { tag: result }
  - { tag: reset, target: 1_START.md }
---
Look at the conversation history and determine if it reflects a successful resolution of the chosen work item.

If the work in the history was unsuccessful or incomplete (not all features implemented or tests not passing or some other failing condition) then:
- Leave the TASK.md file where it is
- Do not stage or commit, (leave files "dirty")
- Respond with message "<result>INCOMPLETE</result>"

If the work in the history reflects a successful completion, then:
- Rename the task file (usually TASK<number>.md) to "TASK-DONE-[datetime].md" including the current time and date
- Then stage the appropriate files (`git add`) and commit.
  - When committing, don't mention Claude Code as a coauthor or contributor
  - Include mention of "Raymond (Agent Orchestrator)" in the commit message
    - Usually you would want to add "Built with Raymond (Agent Orchestrator)" at the end of the commit message
  - After committing, push
- After renaming the TASK file, check if there are any other files named TASK<number>.md
  - If there are no task files, respond with the message "<result>SUCCESS</result>"
  - If there are task files, then respond with the message "<reset>1_START.md</result>"
