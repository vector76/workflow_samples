# plan_to_beads

## Overview

A Raymond workflow that transforms an implementation plan into a structured list
of beads, iteratively reviews and refines that list until it converges, then
creates all beads with their dependencies using the `bs` command.

## Design principles

**Each bead runs in a completely fresh Claude Code context window.** Beads have no
memory of other beads and no knowledge from the plan_to_beads session — only files
on disk. The workflow accounts for this in two ways:

- **Upfront exploration:** before generating beads, the workflow explores the
  codebase and embeds specific file paths and function references directly into each
  bead's description, so beads don't have to rediscover them.
- **Independent beads:** beads are designed to be self-contained units of work. A
  bead can orient itself by reading the project files left by predecessors, just as
  a developer would. Structured handoffs between beads (one bead writing a file for
  the next to read) are a bad pattern and are actively discouraged — research belongs
  in the plan_to_beads process, not spread across bead boundaries.

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
2_EXPLORE_CODEBASE
    |
    v
  existing codebase?
    |              \
   yes              no (greenfield)
    |              /
    v             /
  explore integration points
  (findings held in context)
    \            /
     v          /
3_GENERATE_BEADS_LIST
    |
    v
  create bead_list.md
  (Codebase Notes + Beads)
    |
    v
4_REVIEW_FIX  <─────────────────┐
    |                            |
    v                            |
  review & fix issues            |
    |                            |
    v                            |
5_CHECK_CONVERGENCE              |
    |        \                   |
  fixes      no fixes            |
   made      (converged)         |
    └───────────────────────────┘
                |
                v
           6_CREATE_BEADS
                |
                v
           create all beads
           set up dependencies
           update bead_list.md
                |
                v
           7_VALIDATE
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

Otherwise, reads the implementation plan and proceeds to codebase exploration.

### 2_EXPLORE_CODEBASE.md

Determines whether the plan involves an existing codebase or is greenfield.

For greenfield projects, does nothing and stops immediately.

For plans involving an existing codebase, explores only the specific integration
points the plan refers to — not a general survey. Identifies exact files, functions,
conventions, and test locations. Findings are held in context and written into
`bead_list.md` by the next step.

### 3_GENERATE_BEADS_LIST.md

Creates `bead_list.md` with two sections:

**Codebase Notes** (omitted for greenfield): a summary of exploration findings —
integration points, patterns, test locations. This is a reference used during bead
creation to make descriptions precise, not a handoff mechanism between beads.

**Beads**: each bead is a self-contained, independently executable unit of roughly
30 minutes to 1 hour. Format:

```
### bead-N (placeholder): [Title]
**Work:** [specific description with file paths and function names]
**Estimate:** ~X min
**Dependencies:** [bead names, or "none"]
```

### 4_REVIEW_FIX.md

Reviews bead_list.md against the plan for two categories of issues:

**Coverage and structure:** missing beads, incorrect/missing dependencies, beads
too small to justify or too large (>~2 hours) to not split.

**Fresh-context and independence:** vague work descriptions that leave exploration
to the bead (should use specifics from Codebase Notes); "research beads" that exist
to gather information for later beads (a bad pattern — fold findings into the
relevant bead descriptions or Codebase Notes, then remove the research bead);
unnecessarily sequential dependencies that reflect information transfer rather than
genuine ordering constraints.

### 5_CHECK_CONVERGENCE.md

**Effort: low**

Decision point: if the previous review made fixes, loops back for another cycle.
If nothing was fixed, the bead list has converged and proceeds to creation.

### 6_CREATE_BEADS.md

Creates all beads using the `bs` command in two steps:

**Step 1:** For each bead, composes a self-contained description from the
implementation plan, the bead's Work entry, and the Codebase Notes section.
Creates the bead via `bs`, records the assigned identifier, updates bead_list.md.

**Step 2:** After all beads exist and identifiers are collected, establishes
dependencies between beads using `bs`.

### 7_VALIDATE.md

Verifies all beads were created, identifiers match bead_list.md, and all
dependencies are properly established.

Terminates with `<result>SUCCESS</result>` or `<result>VALIDATION FAILED: ...</result>`.

## Usage

```bash
raymond plan_to_beads/1_START.md --input "my_plan.md"
```

The workflow expects the input to be a filename (not file contents). The
implementation plan should be in the same directory where raymond is executed.

## Terminal States

| Result | Meaning |
|--------|---------|
| `Input unspecified` | No input file was provided via --input parameter. |
| `File not found: ...` | The specified input file does not exist or cannot be read. |
| `SUCCESS` | All beads were created and validated successfully. |
| `VALIDATION FAILED: ...` | Beads were created but validation found discrepancies. |
