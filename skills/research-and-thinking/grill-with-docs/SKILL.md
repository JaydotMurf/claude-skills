---
name: grill-with-docs
description: A relentless codebase-aware interview that sharpens a plan or design and captures decisions as ADRs and glossary entries as it goes. Use when the user explicitly runs /grill-with-docs and has a codebase to interrogate.
tags: [engineering, design, documentation]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
source: mattpocock
---

# Grill With Docs

An interview for sharpening plans that live in a codebase. Unlike `/grill-me`, this skill is stateful — it retains what it learns in `CONTEXT.md` and ADRs.

## Steps

### Step 1 — Run a grilling session with domain modeling active

Run a `/grilling` session, using the `/domain-modeling` skill.

## Guardrails

- Never use this skill without a codebase present; use `/grill-me` instead.
- Never batch CONTEXT.md updates — write each resolved term immediately as it lands.

## Output contract

A sharpened plan plus its decisions persisted to the codebase. Alongside the
in-conversation `grilling` session, each resolved term is written to `CONTEXT.md` as
it lands and significant decisions are captured as ADRs through the `domain-modeling`
skill.

## Verification

The session is done when:

- The `grilling` interview resolved every branch of the design tree.
- Each resolved term and decision was written to `CONTEXT.md` / ADRs as it landed,
  never batched.
- A codebase was present; `CONTEXT.md` and the ADRs reflect the decisions reached.
