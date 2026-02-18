# feat_develop

## Overview

A human-in-the-loop Raymond workflow for collaboratively elaborating a feature
document. Starting from a brief description — as short as a single sentence —
the agent analyzes the codebase, identifies gaps and ambiguities, makes concrete
assumptions, and iteratively refines the document through conversation with the
human until it is complete and well-specified.

The output is the feature document itself, elaborated in place. It is suitable
as input to an implementation workflow.

## Usage

```bash
raymond feat_develop/1_START.md --input "my_feature.md"
```

The `--input` parameter specifies the path to the feature document. The
document is read, refined, and overwritten in place over the course of the
workflow.

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
  document
    |
    v
2_ANALYZE  <────────────────────────────────┐
    |                                        |
    v                                        |
  re-read feature doc                        |
  explore relevant codebase                  |
  identify gaps, errors, ambiguities         |
  write assumptions/issues to                |
  HUMAN_PROMPT.md                            |
  (suggest empty file to finish              |
  if doc is already complete)                |
    |                                        |
    v                                        |
3_PROMPT.sh ··········  shell: wait for human
    |                 \
  human wrote        human left file
  a response         empty
    |                    \
    v                     v
4_RESPONSE             5_CLEANUP.sh
    |                     |
    v                     v
  read HUMAN_PROMPT.md   delete HUMAN_PROMPT.md
  update feature doc     <result>DONE</result>
    |
    v
  <goto>2_ANALYZE</goto>
  (loop)
```

## States

### 1_START.md

Entry point. Validates that an input file was specified via the `--input` CLI
parameter. If `{{result}}` appears as a literal string (not replaced), terminates
with `<result>Input unspecified</result>`.

If the specified file does not exist or cannot be read, terminates with
`<result>File not found: [filename]</result>`.

Otherwise, reads the feature document and proceeds to analysis. The filename
stays in context for all subsequent states — no temp file is needed.

### 2_ANALYZE.md

The loop head. Re-reads the feature document to pick up any changes from the
previous iteration, then explores the parts of the codebase relevant to the
feature (targeted reads and searches rather than broad coverage).

Evaluates the feature document for:

- **Errors or inconsistencies** — contradictions or conflicts with the existing
  codebase
- **Incomplete areas** — functionality mentioned but not fully described,
  including edge cases and error conditions
- **Underspecified areas** — decisions left unmade that a developer would have
  to guess at
- **Ambiguities** — descriptions that could be interpreted in more than one way

For each issue, the agent makes a **concrete assumption** rather than asking an
open-ended question. The human can approve or override with minimal effort.
Direct questions are reserved for cases where no reasonable default exists.

Also flags any implementation detail or code that has crept into the document —
the feature doc should describe *what*, not *how*.

Writes the analysis to `HUMAN_PROMPT.md` (overwriting previous content). If the
document is already complete and well-specified, says so and tells the human
they can leave the file empty to finish.

### 3_PROMPT.sh (script)

Waiting gate that pauses the workflow for human input. Appends a
`<!-- COMPOSING -->` marker to `HUMAN_PROMPT.md`, then polls (via `inotifywait`
with a `sleep` fallback) until the marker is removed.

The human's workflow:
1. Open `HUMAN_PROMPT.md` — see the agent's analysis and the `<!-- COMPOSING -->`
   marker at the bottom.
2. Edit the file: approve assumptions by leaving them, override incorrect ones,
   add missing information, or correct errors.
3. Delete the `<!-- COMPOSING -->` marker and save to signal completion.

Once the marker is gone:

- **Non-empty:** The human responded. Proceed to 4_RESPONSE.
- **Empty (or whitespace-only):** The human is done. Proceed to 5_CLEANUP.

### 4_RESPONSE.md

Reads the human's response from `HUMAN_PROMPT.md` and updates the feature
document accordingly: applying corrections, folding in new information, and
locking in unchallenged assumptions as settled decisions. Transitions back to
2_ANALYZE for the next iteration.

Context is preserved across the loop via `<goto>`, so the agent can see the
full conversation history and the evolution of the document.

### 5_CLEANUP.sh (script)

Terminal state. Deletes `HUMAN_PROMPT.md` and terminates with
`<result>DONE</result>`.

## Human Interaction Protocol

Communication between the agent and the human happens through `HUMAN_PROMPT.md`.

**Agent → Human:** The agent writes its analysis — flagged issues, concrete
assumptions for approval, and any direct questions — then the workflow pauses at
3_PROMPT.sh.

**Human → Agent:** The human edits `HUMAN_PROMPT.md` with corrections and
approvals, then removes the `<!-- COMPOSING -->` marker to signal completion.

**Signaling completion:** To end the workflow, the human clears `HUMAN_PROMPT.md`
(empty or whitespace-only) and removes the marker. The workflow cleans up and
terminates.

## Assumptions vs. Questions

The agent is designed to make choices rather than ask questions. When something
is unclear or underspecified, it picks a reasonable interpretation based on the
codebase and documents it as an assumption. This keeps the iteration fast: the
human reviews a list of concrete statements and only has to act on the ones that
are wrong.

Open-ended questions are used only when there is genuinely no sensible default.

## Feature Document Format

The format of the feature document is open — the agent shapes it to fit the
scope and complexity of the feature. A small feature may warrant a short, direct
description; a larger one may grow sections for behavior, edge cases, acceptance
criteria, and integration points.

The document should describe **what** the feature does. Code should be minimal
or absent. Implementation choices belong in design documents or code comments,
not here.

## Context Management

The workflow never uses `<reset>`, so the Claude Code session is preserved
across all loop iterations. The filename from `--input` stays in context
throughout, and the agent can reference the full conversation history —
including the evolution of the document — across analysis passes. This is
appropriate because the number of iterations is small and the history is
useful context.

## Files

| File | Purpose |
|------|---------|
| `[input file]` | The feature document being elaborated (persistent output, modified in place) |
| `HUMAN_PROMPT.md` | Ephemeral communication channel between agent and human (deleted on completion) |

## Terminal States

| Result | Meaning |
|--------|---------|
| `Input unspecified` | No input file was provided via `--input`. |
| `File not found: ...` | The specified input file does not exist or cannot be read. |
| `DONE` | The human signaled completion by leaving `HUMAN_PROMPT.md` empty. The feature document contains the final elaborated spec. |
