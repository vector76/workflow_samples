---
allowed_transitions:
  - { tag: result, payload: "DONE" }
---
You know the in_progress filename from earlier in this conversation.

Delete `HUMAN_PROMPT.md` and `HUMAN_RESPONSE.md` if they exist.

Rename the in_progress file to the corresponding fullspec filename by replacing
the `in_progress_` prefix with `fullspec_`. For example,
`in_progress_add_green_button.md` becomes `fullspec_add_green_button.md`.

Derive the underspec filename by replacing the `in_progress_` prefix with
`underspec_`. If the fullspec file now exists, delete the underspec file.

STOP after the rename and deletions. Do not modify the fullspec or create any files.

After completing, respond with exactly:
<result>DONE</result>
