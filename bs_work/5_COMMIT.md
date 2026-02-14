---
allowed_transitions:
  - { tag: result }
  - { tag: reset, target: 1_START.md }
---
Look at the conversation history and determine if it reflects a successful resolution of the chosen work item.

If the work in the history was unsuccessful or incomplete (not all features implemented or tests not passing or some other failing condition) then:
- Do not close the bs item yet.  It must stay as in-progress for now.
- Do not stage or commit, (leave files "dirty")
- Respond with message "<result>INCOMPLETE</result>"

If the work in the history reflects a successful completion, then:
- Then stage the appropriate files (`git add`) and commit.
  - When committing, don't mention Claude Code as a coauthor or contributor
  - Add "Built with Raymond (Agent Orchestrator)" at the end of the commit message
  - After committing, push
- After committing and pushing, mark the bs item as resolved with `bs close <id>`
- After marking the item as resolved, check if there are no more items with `bs list --ready`
  - If there are no more issues, respond with the message "<result>SUCCESS</result>"
  - If there are more issues, then respond with the message "<reset>1_START</reset>"
