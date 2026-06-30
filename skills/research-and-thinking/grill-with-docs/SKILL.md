---
name: grill-with-docs
description: A relentless codebase-aware interview that sharpens a plan or design and captures decisions as ADRs and glossary entries as it goes. Use when the user explicitly runs /grill-with-docs and has a codebase to interrogate.
tags: [engineering, design, documentation]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
source: mattpocock
standard: upstream-vendored
---

# Grill With Docs

An interview for sharpening plans that live in a codebase. Unlike `/grill-me`, this skill is stateful — it retains what it learns in `CONTEXT.md` and ADRs.

## Steps

### Step 1 — Run a grilling session with domain modeling active

Run a `/grilling` session, using the `/domain-modeling` skill.

## Guardrails

- Never use this skill without a codebase present; use `/grill-me` instead.
- Never batch CONTEXT.md updates — write each resolved term immediately as it lands.
