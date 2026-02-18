---
allowed_transitions:
  - { tag: result }
---
Validate that all beads were created correctly:

1. Use `bs` commands to list and inspect the beads that were just created
2. Compare the created beads against bead_list.md to ensure all beads were created
3. Verify that all dependencies specified in bead_list.md have been properly
   established between the beads
4. Check that bead identifiers in bead_list.md match the actual created beads
5. Verify that no beads remain in `not_ready` status — all should have been flipped
   to `open` after dependencies were set up

If everything is validated successfully, respond with:
<result>SUCCESS</result>

If validation fails, include details about what went wrong in the result:
<result>VALIDATION FAILED: [describe the issue]</result>
