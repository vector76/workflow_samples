# plan_to_beads

## Overview

A Raymond workflow that transforms an implementation plan into a structured list
of beads, iteratively reviews and refines that list until it converges, then
creates all beads with their dependencies using the `bs` command.

## Workflow

```
1_START
    |
    v
  input specified?
    |          \
   yes          no
    |            \
    v             v
  read plan   <result>Input unspecified</result>
    |
    v
2_GENERATE_BEADS_LIST
    |
    v
  create bead_list.md
    |
    v
3_REVIEW_FIX  <─────────────────┐
    |                            |
    v                            |
  review & fix issues            |
    |                            |
    v                            |
4_CHECK_CONVERGENCE              |
    |        \                   |
  fixes      no fixes            |
   made      (converged)         |
    |           \                |
    └───────────┘                |
                |
                v
           5_CREATE_BEADS
                |
                v
           create all beads
           set up dependencies
           update bead_list.md
                |
                v
           6_VALIDATE
                |
                v
           validate beads
                |
                v
           <result>SUCCESS</result>
           or
           <result>VALIDATION FAILED</result>
```

## States

### 1_START.md

Entry point. Validates that an input file was specified via the `--input` CLI
parameter. If `{{result}}` appears as a literal string (not replaced), terminates
with `<result>Input unspecified</result>`.

If the specified file does not exist or cannot be read, terminates with
`<result>File not found: [filename]</result>`.

Otherwise, reads the implementation plan from the specified file and proceeds to
generate the bead list.

### 2_GENERATE_BEADS_LIST.md

Transforms the implementation plan into a structured markdown list of beads.
Creates `bead_list.md` with:
- All beads to be created
- What work is included in each bead
- Dependencies between beads

The list uses placeholder names initially; actual bead identifiers (like bd-xk2a3)
are added later during creation.

### 3_REVIEW_FIX.md

Reviews bead_list.md against the original implementation plan for issues:
- Missing beads or incomplete coverage
- Incorrect or unclear dependencies
- Dependencies that reference non-existent beads
- Improper bead scope (too large or too small)
- Any other errors or improvements

Automatically fixes major and minor issues. "Not a bug" observations are optional
and don't require fixing.

### 4_CHECK_CONVERGENCE.md

**Effort: low** (uses extended thinking at low effort for faster execution)

Decision point that examines the previous review to determine if fixes were made.

- If major or minor fixes were applied: loops back to 3_REVIEW_FIX for another
  review cycle.
- If nothing was fixed (everything is correct, or only "not a bug" observations):
  proceeds to 5_CREATE_BEADS.

This convergence loop ensures high quality by iteratively refining the bead list
until no further improvements are found.

### 5_CREATE_BEADS.md

Creates all beads using the `bs` command in two steps:

**Step 1:** Create all beads
- For each bead in bead_list.md, creates it with appropriate title and description
  from the implementation plan
- Records the assigned bead identifier (e.g., bd-xk2a3)
- Updates bead_list.md to include the identifier

**Step 2:** Set up all dependencies
- After ALL beads exist and identifiers are collected, establishes dependencies
  between beads using the `bs` command

This two-step approach ensures all bead IDs are available before setting up
dependencies. After all beads are created and linked, proceeds to validation.

### 6_VALIDATE.md

Post-creation validation step that verifies:
- All beads from bead_list.md were created
- Bead identifiers in bead_list.md match actual created beads
- All specified dependencies were properly established

Terminates with:
- `<result>SUCCESS</result>` if validation passes
- `<result>VALIDATION FAILED: ...</result>` if issues are found

## Usage

```bash
raymond plan_to_beads/1_START.md --input "my_plan.md"
```

The workflow expects the input to be a filename (not file contents). The
implementation plan should be in the same directory where raymond is executed.

## Review Loop

The 3_REVIEW_FIX / 4_CHECK_CONVERGENCE cycle forms an iterative refinement loop.
Each pass through REVIEW_FIX examines the bead list and applies fixes. The
CHECK_CONVERGENCE step determines if another review is needed based on whether
fixes were made. The loop exits only when a review pass finds nothing to fix,
ensuring high-quality output before bead creation begins.

This pattern is similar to the bs_work workflow's review loop, ensuring thorough
quality checking through iteration.

## Context Management

All states use `<goto>` transitions, preserving the Claude Code session context
throughout the workflow. This allows later states to reference:
- The original implementation plan
- The evolution of bead_list.md through review cycles
- The full history of what was created and validated

## Terminal States

| Result | Meaning |
|--------|---------|
| `Input unspecified` | No input file was provided via --input parameter. |
| `File not found: ...` | The specified input file does not exist or cannot be read. |
| `SUCCESS` | All beads were created and validated successfully. |
| `VALIDATION FAILED: ...` | Beads were created but validation found discrepancies. |
