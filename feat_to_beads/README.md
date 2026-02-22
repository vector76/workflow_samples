# feat_to_beads

## Overview

A Raymond workflow that takes a feature specification document and produces a
set of implementation beads. It runs in two phases separated by a context reset:

**Phase 1 — Plan**: explores the codebase, writes `plan.md`, and iteratively
refines it through a review loop until it converges.

**Phase 2 — Beads**: reads `plan.md` in a fresh context, explores codebase
integration points, generates `bead_list.md`, iteratively refines it, then
creates all beads with their dependencies.

## Usage

```bash
raymond feat_to_beads/ --input "my_feature.md"
```

The `--input` parameter specifies the path to the feature specification document.

## Preconditions

The workflow aborts at startup if either `plan.md` or `bead_list.md` already
exists in the working directory. Remove or rename these files before running.

## Workflow

```
1_START
    |
    v
  input specified?
  plan.md & bead_list.md absent?
  feature file readable?
    |          \
  all pass      any fail
    |                 \
    v                  v
  read feature    <result>...</result>
  document
    |
    v
2_DRAFT_PLAN
    |
    v
  re-read feature doc
  explore relevant codebase
  write plan.md
    |
    v
3_REVIEW_PLAN  <──────────────────────────┐
    |                                     |
    v                                     |
  re-read plan.md & feature doc           |
  fix missing steps,                      |
  dependency violations,                  |
  coverage gaps,                          |
  over/under-specification                |
    |                                     |
    v                                     |
4_CHECK_PLAN                              |
    |                   \                 |
  fixes made             no fixes         |
    └────────────────────────────────────►┘
                         |
                         v
                   [context reset]
                         |
                         v
                   5_EXPLORE_CODEBASE
                         |
                         v
                   read plan.md
                   explore integration points
                   (if not greenfield)
                         |
                         v
                   6_GENERATE_BEADS_LIST
                         |
                         v
                   write bead_list.md
                         |
                         v
                   7_REVIEW_BEADS  <──────────────────┐
                         |                            |
                         v                            |
                   review & fix bead_list.md          |
                         |                            |
                         v                            |
                   8_CHECK_BEADS                      |
                         |            \               |
                       fixes           no fixes       |
                        made          (converged)     |
                         └───────────────────────────►┘
                                       |
                                       v
                                 9_CREATE_BEADS
                                       |
                                       v
                                 create all beads
                                 set up dependencies
                                 open dependent beads
                                       |
                                       v
                                 10_VALIDATE
                                       |
                                       v
                                 <result>SUCCESS</result>
                                 or
                                 <result>VALIDATION FAILED</result>
```

## States

### 1_START.md

Entry point. Validates the input and preconditions:
- If no `--input` was provided: terminates with `<result>Input unspecified</result>`
- If `plan.md` already exists: terminates with `<result>Aborted: plan.md already exists</result>`
- If `bead_list.md` already exists: terminates with `<result>Aborted: bead_list.md already exists</result>`
- If the feature file cannot be read: terminates with `<result>File not found: ...</result>`

Otherwise, reads the feature document and confirms that `plan.md` will be the output.

### 2_DRAFT_PLAN.md

Re-reads the feature document and explores the parts of the codebase relevant to
the feature (targeted searches, not a full survey). Writes `plan.md` as a
strategic, implementation-free plan structured in sequential phases.

### 3_REVIEW_PLAN.md

Re-reads `plan.md` and the feature document and checks for:

- **Missing steps** — work required by a later step that is not yet planned
- **Dependency violations** — steps that assume prior work not yet done
- **Coverage gaps** — aspects of the feature document not addressed
- **Over-specification** — code, names, or low-level decisions that belong in implementation
- **Under-specification** — steps too vague to guide an implementer
- **Strategic clarity** — whether each phase clearly conveys what success looks like

Issues are fixed directly in `plan.md`.

### 4_CHECK_PLAN.md

**Effort: low**

Decision point. If fixes were made in the previous review, loops back to
`3_REVIEW_PLAN`. If the plan has converged (nothing was changed), resets context
and transitions to the bead generation phase.

### 5_EXPLORE_CODEBASE.md

Runs in a fresh context. Reads `plan.md`. If the plan involves an existing
codebase, explores the specific integration points the plan refers to — exact
files, functions, conventions, and test locations. For greenfield projects, does
nothing and proceeds immediately.

### 6_GENERATE_BEADS_LIST.md

Creates `bead_list.md` with two sections:

**Codebase Notes** (omitted for greenfield): integration points, patterns, test
locations — a reference for precise bead descriptions, not a handoff between beads.

**Beads**: each bead is a self-contained unit of roughly 30 minutes to 1 hour,
with specific file paths and function names in the Work description.

### 7_REVIEW_BEADS.md

Reviews `bead_list.md` against `plan.md` for coverage, structure, and
fresh-context independence. Fixes issues directly in the file.

### 8_CHECK_BEADS.md

**Effort: low**

Decision point. If fixes were made, loops back to `7_REVIEW_BEADS`. If the bead
list has converged, proceeds to bead creation.

### 9_CREATE_BEADS.md

Creates all beads in three steps:

1. Creates each bead (open if no dependencies; `not_ready` if dependencies exist).
   Records each assigned identifier in `bead_list.md`.
2. After all beads exist, establishes all dependencies between them.
3. Flips all `not_ready` beads to `open`.

This sequence ensures no bead can be claimed before its prerequisites are registered.

### 10_VALIDATE.md

Verifies all beads were created, identifiers match `bead_list.md`, all
dependencies are properly established, and no beads remain in `not_ready` status.
Terminates with `<result>SUCCESS</result>` or `<result>VALIDATION FAILED: ...</result>`.

## Context management

Phase 1 (states 1–4) uses `<goto>` throughout, keeping the feature document
content and the Claude Code session in context across the plan review loop.

The `<reset>` at `4_CHECK_PLAN` is the phase boundary. All prior context is
discarded — this is intentional, as the planning session's accumulated exploration
and reasoning would otherwise pollute the bead generation phase. The plan itself
is on disk in `plan.md`, which is all phase 2 needs.

Phase 2 (states 5–10) uses `<goto>` throughout, keeping `plan.md` contents and
codebase exploration findings in context across the bead review loop.

## Terminal states

| Result | Meaning |
|--------|---------|
| `Input unspecified` | No input file was provided via `--input`. |
| `Aborted: plan.md already exists` | `plan.md` is present in the working directory. |
| `Aborted: bead_list.md already exists` | `bead_list.md` is present in the working directory. |
| `File not found: ...` | The specified feature document does not exist or cannot be read. |
| `SUCCESS` | All beads were created and validated successfully. |
| `VALIDATION FAILED: ...` | Beads were created but validation found discrepancies. |
