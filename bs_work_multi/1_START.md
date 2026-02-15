---
allowed_transitions:
  - { tag: goto, target: CLAIM_TASK.md }
  - { tag: result }
---
Check that the beads server credentials are configured.

Run `bs whoami` — if it lists "anonymous" as the user, we don't have a
username.

Run `bs list` — if it produces an error "BS_TOKEN is required", we don't
have a token.

If either of these is the case, stop and respond with
"<result>NOT CONFIGURED</result>".

If both are configured, respond with "<goto>CLAIM_TASK</goto>" to begin
claiming work.
