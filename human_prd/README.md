# human_prd

## Overview

A human-in-the-loop Raymond workflow for collaboratively building a
Product Requirements Document (PRD). The agent drafts and refines
`PRD.md` through iterative conversation with a human, using
`HUMAN_PROMPT.md` as a shared communication channel.

The workflow loops until the human signals that the PRD is complete
by leaving `HUMAN_PROMPT.md` empty (or whitespace-only).

## Workflow

```
1_START
    |
    v
  PRD.md exists?
    |          \
   yes          no
    |            \
    v             v
  review it    write "what are you
  write          wanting to do?"
  assumptions/   to HUMAN_PROMPT.md
  questions to
  HUMAN_PROMPT.md
    |            |
    v            v
2_PROMPT.sh ··········  $0 script: wait for human
    |                 \
  human wrote        human left file
  a response         empty
    |                    \
    v                     v
3_RESPONSE             4_CLEANUP.sh
    |                     |
    v                     v
  read HUMAN_PROMPT.md   delete HUMAN_PROMPT.md
  refine/create PRD.md   <result>DONE</result>
    |
    v
  <reset>1_START</reset>
  (loop)
```

## States

### 1_START.md

Entry point. Checks whether `PRD.md` exists in the working directory.

**If PRD.md does not exist:** Writes "what are you wanting to do?" to
`HUMAN_PROMPT.md` — the first prompt to the human.

**If PRD.md exists:** Reads it and evaluates whether everything makes
sense or if more clarification is needed. Writes assumptions, questions,
or other clarifications to `HUMAN_PROMPT.md`.

The workflow prefers stating explicit assumptions over asking open-ended
questions, since it is faster and easier for the human to approve or
override a concrete choice than to explain from scratch.

Has a single implicit transition to 2_PROMPT.

### 2_PROMPT.sh (script, $0)

Waiting gate that pauses the workflow for human input. Appends a
`<!-- COMPOSING -->` marker to `HUMAN_PROMPT.md`, then polls (via
`inotifywait` with a `sleep` fallback) until the marker is removed.

The human's editor workflow:
1. Open `HUMAN_PROMPT.md` — see the agent's questions/assumptions with
   the `<!-- COMPOSING -->` marker at the bottom.
2. Write responses, corrections, or approvals.
3. Delete the `<!-- COMPOSING -->` marker and save to signal completion.

Once the marker is gone, the script checks whether the file has content:

- **Non-empty:** The human responded. Proceed to 3_RESPONSE.
- **Empty (or whitespace-only):** The human is done. Proceed to
  4_CLEANUP.

### 3_RESPONSE.md

Reads the human's response from `HUMAN_PROMPT.md` and uses it to
refine or create `PRD.md`. Transitions with `<reset>1_START</reset>`,
discarding context and starting a fresh session for the next iteration.

The reset is appropriate here because all state is captured in `PRD.md`
— the agent re-reads it at the top of each loop.

### 4_CLEANUP.sh (script, $0)

Terminal state. Deletes `HUMAN_PROMPT.md` (no longer needed) and
terminates the workflow with `<result>DONE</result>`.

## Human Interaction Protocol

Communication between the agent and the human happens through a single
file: `HUMAN_PROMPT.md`.

**Agent → Human:** The agent writes questions, assumptions, or prompts
to `HUMAN_PROMPT.md`, then the workflow enters the 2_PROMPT.sh waiting
gate.

**Human → Agent:** The human edits `HUMAN_PROMPT.md` with their
response, then removes the `<!-- COMPOSING -->` marker to signal that
the response is ready.

**Signaling completion:** To end the workflow, the human clears
`HUMAN_PROMPT.md` (empty or whitespace-only) and removes the marker.
The workflow cleans up and terminates.

The `<!-- COMPOSING -->` marker serves as a simple synchronization
mechanism — the script won't proceed while the human is still writing.

## Context Management

Every iteration uses `<reset>` to start with a fresh context. This is
by design: the PRD itself (`PRD.md`) is the persistent artifact, and
the agent re-reads it at the start of each loop. There is no need to
carry conversation history across iterations, and fresh context avoids
accumulating noise from previous rounds of questions and answers.

## Files

| File | Purpose |
|------|---------|
| `PRD.md` | The product requirements document being built (persistent output) |
| `HUMAN_PROMPT.md` | Ephemeral communication channel between agent and human (deleted on completion) |

## Terminal States

| Result | Meaning |
|--------|---------|
| `DONE` | The human signaled completion by leaving `HUMAN_PROMPT.md` empty. `PRD.md` contains the final PRD. |
