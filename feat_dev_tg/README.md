The purpose is to take an underspecified, concise starting document describing 
a feature and collaboratively extrapolate into a full description of the 
desired feature.

A naming convention of `underspec_<name>.md` is used to indicate inputs to this
process, for example `underspec_add_green_button.md`.  While being refined, the
working document uses the naming convention `in_progress_<name>.md`.  The final
outputs follow the naming convention `fullspec_<name>.md` — the rename from
`in_progress_` to `fullspec_` happens only at the very end, so a watcher can
reliably treat `fullspec_*` as a completed signal.  The underspecified documents
are deleted once the fully specified documents are complete.

This workflow should pick an underspecified document, copy it to an in_progress
file, refine it collaboratively, and then rename it to fullspec when complete,
similar to the workflow described in `../../workflow_samples/feat_develop/`.

**START.sh**
Look for an `underspec_*.md` file where neither a corresponding `in_progress_`
nor a corresponding `fullspec_` file exists.

If no eligible underspec files exist, then `<result>DONE</result>`.

If an underspec file has been found, copy it to the corresponding `in_progress_`
filename and then call
`<function return="DONE" input="(in_progress file)">ANALYZE</function>`

**ANALYZE**
Analyze `{{result}}` (the `in_progress` file) and expand on it and collect any
questions or assumptions into `HUMAN_PROMPT.md`.

Then `<goto>PROMPT</goto>`

**PROMPT.sh**
Run `tgask` to send the query to the human and get the response.  Use command 
line parameters `-f` and `-o` to specify the input `HUMAN_PROMPT.md` and 
output `HUMAN_RESPONSE.md`.

If the human response contains nothing but the single word "done", then delete
the human prompt and human response and finish with `<goto>CLEANUP</goto>`

If the last line of the human response is the single word "done" (but there is
more to the response than just that) then `<goto>FINAL_RESPONSE</goto>`.

Otherwise, `<goto>RESPONSE</goto>`.

**RESPONSE**
Take the `in_progress` file and `HUMAN_PROMPT.md` and `HUMAN_RESPONSE.md` and combine them
into an updated `in_progress` file.

Delete the prompt and response files.

Then analyze for any remaining questions or assumptions, or if the previous 
response opens new questions or assumptions, write them to `HUMAN_PROMPT.md`.

Then `<goto>PROMPT</goto>`.

**FINAL_RESPONSE**
Take the `in_progress` file and `HUMAN_PROMPT.md` and `HUMAN_RESPONSE.md` and combine them
into an updated `in_progress` file.

Delete the prompt and response files.

Then finish with `<goto>CLEANUP</goto>`

**CLEANUP**
Check if `HUMAN_PROMPT.md` or `HUMAN_RESPONSE.md` exist and delete them if
they do.

Rename the `in_progress_` file to the corresponding `fullspec_` filename.

If the fullspec file now exists, delete the underspec file.

Finish with `<result>DONE</result>`.

**DONE.sh**
Just echo `<reset>START</reset>`