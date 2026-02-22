---
allowed_transitions:
  - { tag: goto, target: PUSH_GATE.sh }
  - { tag: goto, target: BAIL_OUT.md }
---
Look at the conversation history and determine if it reflects a successful
resolution of the chosen work item.

If the work in the history was unsuccessful or incomplete (not all features
implemented or tests not passing or some other failing condition) then:
- Do not close the bs item yet.  It must stay as in-progress for now.
- Do not stage or commit.
- Respond with "<goto>BAIL_OUT</goto>" to abandon this task and release it
  for another agent to attempt.

If the work in the history reflects a successful completion, then:
- Stage the appropriate files (`git add`) and commit.
  - When committing, don't mention Claude Code as a coauthor or contributor.
  - Add "Built with Raymond (Agent Orchestrator)" at the end of the commit
    message.
- Do NOT push yet — the push loop will handle that.
- Do NOT close the bs item yet.
- Respond with "<goto>PUSH_GATE.sh</goto>" to enter the push loop.
