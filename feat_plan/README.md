# feat_plan

## Overview

A Raymond workflow that takes a feature document and produces a detailed,
high-level implementation plan. The plan is thorough and complete — covering
all meaningful aspects of the feature — but contains little to no code. The
focus is on strategy, sequencing, and dependencies so that an implementer can
proceed from start to finish without hitting missing pieces.

The workflow performs targeted codebase research to ground the plan in the
existing architecture, then iteratively refines it through a review loop until
no further improvements are found.

## Usage

```bash
raymond feat_plan/1_START.md --input "my_feature.md"
```

The `--input` parameter specifies the path to the feature document. The output
plan filename is derived from the input: the basename is taken (directory
stripped), the `.md` extension is removed, and `_plan.md` is appended. For
example, `features/auth_flow.md` produces `auth_flow_plan.md` in the directory
where `raymond` is run.

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
  read feature  <result>Input unspecified</result>
  document,
  derive plan
  filename
    |
    v
2_DRAFT_PLAN
    |
    v
  re-read feature doc
  explore relevant codebase
  write [feature]_plan.md
    |
    v
3_REVIEW_FIX  <──────────────────────────┐
    |                                     |
    v                                     |
  re-read plan & feature doc              |
  fix missing steps,                      |
  dependency violations,                  |
  coverage gaps,                          |
  over/under-specification                |
    |                                     |
    v                                     |
4_CHECK_CONVERGENCE                       |
    |                   \                 |
  fixes made             no fixes         |
    |                    (converged)      |
    └────────────────────────────────────►┘
                         |
                         v
           <result>[feature]_plan.md</result>
```

## States

### 1_START.md

Entry point. Validates that an input file was specified via the `--input` CLI
parameter. If `{{result}}` appears as a literal string (not replaced), terminates
with `<result>Input unspecified</result>`.

If the specified file does not exist or cannot be read, terminates with
`<result>File not found: [filename]</result>`.

Otherwise, reads the feature document, derives the plan output filename
(basename, `.md` stripped, `_plan.md` appended), and states it explicitly so it
remains in context for all subsequent steps.

### 2_DRAFT_PLAN.md

Explores the parts of the codebase relevant to the feature (targeted searches
rather than broad coverage), then writes the plan file.

The plan is structured as sequential phases. Where relevant, each phase states
its goal, the strategic work to be done, what prior phases must have delivered,
and what it delivers for subsequent phases — adapted to the complexity of the
feature. Code and implementation detail are explicitly excluded.

### 3_REVIEW_FIX.md

Re-reads the plan file with fresh eyes and checks for:

- **Missing steps** — work required by a later step that is not yet planned
- **Dependency violations** — steps that assume prior work not yet done
- **Coverage gaps** — aspects of the feature document not addressed
- **Over-specification** — code, names, or low-level decisions that belong in
  the implementation, not the plan
- **Under-specification** — steps too vague to guide an implementer
- **Strategic clarity** — whether each phase clearly conveys what success looks like

Issues are fixed directly in the file. The state explicitly reminds the agent
that we are producing a strategic plan, not writing the implementation.

### 4_CHECK_CONVERGENCE.md

**Effort: low**

Decision point that examines the previous review to determine if fixes were
applied.

- If meaningful fixes were made: loops back to 3_REVIEW_FIX for another pass.
- If nothing was fixed: the plan has converged and the workflow terminates with
  `<result>[feature]_plan.md</result>` (the actual derived filename).

## Review Loop

The 3_REVIEW_FIX / 4_CHECK_CONVERGENCE cycle is the quality gate. Each pass
reviews the plan and applies fixes. The loop exits only when a review pass finds
nothing to fix, ensuring the plan is complete and well-structured before the
workflow ends.

## What the Plan Contains

The output plan is designed to be:

- **Strategic**: what must be accomplished at each phase, not how to code it
- **Sequential**: phases ordered so each builds on what came before
- **Dependency-explicit**: prerequisites called out clearly
- **Complete**: all aspects of the feature addressed with no gaps that would
  block implementation

The plan is intentionally free of code snippets and implementation-level
decisions. The implementer reads the plan alongside the existing codebase and
makes those decisions themselves.

## Context Management

All states use `<goto>` transitions, preserving the Claude Code session
throughout. The feature document filename and codebase research stay in context
across the review loop, so each review pass has the full picture without
re-reading from scratch.

## Terminal States

| Result | Meaning |
|--------|---------|
| `Input unspecified` | No input file was provided via `--input`. |
| `File not found: ...` | The specified input file does not exist or cannot be read. |
| `[feature]_plan.md` | The plan was produced and refined to convergence. The result payload is the plan filename. |
