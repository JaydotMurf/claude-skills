---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up. Use when the user explicitly runs /handoff or needs to continue work in a fresh session.
tags: [productivity, workflow, sessions]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
source: mattpocock
standard: upstream-vendored
---

# Handoff

Compact the current conversation into a durable markdown document so a fresh session can continue the work without losing context.

Use this when a thread is full, when branching off into a prototype session, or whenever you need a fresh context window but must preserve the current conversation.

## Steps

### Step 1 — Write the handoff document

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save it to the OS temporary directory — not the current workspace.

Include a "suggested skills" section that names which skills the next agent should invoke.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information: API keys, passwords, personally identifiable information.

If the user passed an argument, treat it as a description of what the next session will focus on and tailor the document accordingly.

## Guardrails

- Never save the handoff document to the workspace — always write to the OS temp directory.
- Never duplicate content from existing artifacts — reference them by path or URL.
- Never include credentials, API keys, or PII in the handoff document.
