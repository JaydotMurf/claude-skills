---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up. Use when the user explicitly runs /handoff or needs to continue work in a fresh session.
tags: [productivity, workflow, sessions]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
source: mattpocock
---

# Handoff

Compact the current conversation into a durable markdown document so a fresh session can continue the work without losing context.

Use this when a thread is full, when branching off into a prototype session, or whenever you need a fresh context window but must preserve the current conversation.

## Steps

### Step 1 — Write the handoff document

Write a handoff document summarising the current conversation so a fresh agent can continue the work.

Save it to the OS temporary directory — never the current workspace — under a stable, project-scoped name so a fresh session can find it. Resolve the temp directory from `$TMPDIR` (falling back to `/tmp`) and the project slug from the basename of the git repo root (`git rev-parse --show-toplevel`, falling back to the current directory), then write to `${TMPDIR:-/tmp}/session-handoff-<project-slug>-<timestamp>.md` — for example `/tmp/session-handoff-agent-skills-2026-07-02-153045.md`. This is the exact location and naming convention that `starting-project-session` searches on startup, so keep the two in sync.

Include a "suggested skills" section that names which skills the next agent should invoke.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information: API keys, passwords, personally identifiable information.

If the user passed an argument, treat it as a description of what the next session will focus on and tailor the document accordingly.

## Guardrails

- Never save the handoff document to the workspace — always write to the OS temp directory.
- Never invent an ad-hoc filename — use the `session-handoff-<project-slug>-<timestamp>.md` convention so `starting-project-session` can discover the file.
- Never duplicate content from existing artifacts — reference them by path or URL.
- Never include credentials, API keys, or PII in the handoff document.

## Output contract

A durable handoff markdown document written to the OS temporary directory, never the
workspace, at `${TMPDIR:-/tmp}/session-handoff-<project-slug>-<timestamp>.md` so
`starting-project-session` can locate it. It summarizes the current conversation, carries
a "suggested skills" section naming what the next agent should invoke, references existing
artifacts (PRDs, plans, ADRs, issues, commits) by path or URL instead of duplicating them,
redacts secrets, and — when an argument was passed — is tailored to that next focus.

## Verification

The handoff is done when:

- The document exists in the OS temp directory, not the workspace, and its filename
  follows the `session-handoff-<project-slug>-<timestamp>.md` convention.
- It names the skills the next agent should invoke and references existing artifacts
  rather than duplicating their content.
- It contains no credentials, API keys, or PII.
