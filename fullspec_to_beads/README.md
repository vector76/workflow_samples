Similar in spirit to feat_to_beads but it looks in the filesystem for a file 
named `fullspec_<name>.md` to use as input.  In this way it can work in 
conjunction with feat_dev_tg.

Also using all my lessons about using shell scripts together with .md files.

**START.sh**
Look for a `fullspec_<name>.md` file where there is no `plan_<name>.md` or 
`beads_<name>.md` file.

If no eligible fullspec files exist, then `<result>DONE</result>`.

If a fullspec file has been found,
`<function return="DONE" input="(fullspec file)">DRAFT_PLAN</function>

**DRAFT_PLAN**
Reads the feature document and explores the parts of the codebase relevant to
the feature (targeted searches, not a full survey). Writes `plan_<name>.md` as 
a strategic, implementation-free plan structured in sequential phases.

`<goto>REVIEW_PLAN</goto>`

**REVIEW_PLAN**
Check again with fresh eyes.

`<call return="PLAN_AGAIN_CHOICE">PLAN_DID_FIX</call>`

**PLAN_DID_FIX**
If the previous check fixed anything, respond `YES`, otherwise respond `NO`.

**PLAN_AGAIN_CHOICE.sh**
If the input is `YES` then `<goto>REVIEW_PLAN</goto>`
If the input is `NO` then `<goto>TRANSITION</goto>`

**TRANSITION**
Invoke `<reset input=(plan file name)>EXPLORE_CODEBASE</reset>`

**EXPLORE_CODEBASE**
Read `plan_<name>.md` explore integration points if not greenfield.

And generate beads list.  Write `beads_<name>.md`.

**REVIEW_BEADS**
Check again with fresh eyes

`<call return="BEADS_AGAIN_CHOICE">BEADS_DID_FIX</call>`

**BEADS_DID_FIX**
If the previous check fixed anything, respond `YES`, otherwise respond `NO`.

**BEADS_AGAIN_CHOICE.sh**
If the input is `YES` then `<goto>REVIEW_BEADS</goto>`
If the input is `NO` then `<goto>CREATE_BEADS</goto>`

**CREATE_BEADS**
Create all beads, set up dependencies, open dependent beads.

`<goto>VALIDATE</goto>`

**VALIDATE**
Validate beads are set up properly.

`<result>SUCCESS</result>`
or
`<result>VALIDATION FAILED</result>`

