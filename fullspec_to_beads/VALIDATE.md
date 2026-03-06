---
allowed_transitions:
  - { tag: result }
---
Validate that all beads were created correctly:

1. Use `bs` commands to list and inspect the beads that were just created
2. Compare the created beads against the beads file to ensure all beads were created
3. Verify that all dependencies specified in the beads file have been properly
   established between the beads
4. Check that bead identifiers in the beads file match the actual created beads
5. Verify that no beads remain in `not_ready` status — all should have been flipped
   to `open` after dependencies were set up. Beads that have already progressed to
   `in_progress` or beyond are fine; what matters is that none were left in `not_ready`.

If everything is validated successfully, respond with:
<result>SUCCESS</result>

If validation fails, include details about what went wrong in the result:
<result>VALIDATION FAILED: [describe the issue]</result>
