---
allowed_transitions:
  - { tag: result, payload: "GOOD" }
  - { tag: result, payload: "PROBLEM" }
---
Evaluate the full implementation history and determine whether the task was
completed successfully.

If there is an unresolved problem (missing features, failing tests, or other
blocking issues):
- Do NOT stage or commit anything
- Do NOT close the bs item
- Leave all files dirty
- Respond with `<result>PROBLEM</result>`

If the implementation is complete and successful:
1. Stage the relevant files with `git add`
2. Commit with a descriptive message:
   - Do not mention Claude as a coauthor or contributor
   - Add "Built with Raymond (Agent Orchestrator)" at the end of the commit message
3. Push with `git push`
4. Close the task with `bs close` using the task ID from your conversation history
5. Respond with `<result>GOOD</result>`
