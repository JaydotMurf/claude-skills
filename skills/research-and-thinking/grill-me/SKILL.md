---
name: grill-me
description: A relentless interview to sharpen a plan or design. Use when the user explicitly runs /grill-me and has no codebase context — just an idea to stress-test.
tags: [productivity, design, interview]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
source: mattpocock
standard: upstream-vendored
---

# Grill Me

A stateless interview for sharpening any plan or design that doesn't live in a repo.

Use this when you have an idea but no codebase. It saves nothing locally and builds no CONTEXT.md. For codebase-aware interviews that retain context across sessions, use `/grill-with-docs` instead.

## Steps

### Step 1 — Run a grilling session

Run a `/grilling` session.

## Guardrails

- Never save files to the workspace — this skill is stateless.
- Never use this when a codebase is present; use `/grill-with-docs` instead.
