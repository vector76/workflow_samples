---
allowed_transitions:
  - { tag: goto, target: PUSH_ATTEMPT }
  - { tag: goto, target: BAIL_OUT }
---
Evaluate the full implementation history and determine whether the task was
completed successfully.

If there is an unresolved problem (missing features, failing tests, or other
blocking issues):
- Do NOT stage or commit anything
- Do NOT close the bm item
- Leave all files dirty
- Respond with `<goto>BAIL_OUT</goto>`

If the implementation is complete and successful:
1. Stage the relevant files with `git add`
2. Commit with a descriptive message:
   - Do not mention Claude as a coauthor or contributor
3. Do NOT push — that is handled by PUSH_ATTEMPT
4. Do NOT close the bm item yet
5. Respond with `<goto>PUSH_ATTEMPT</goto>`
