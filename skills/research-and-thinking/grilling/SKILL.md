---
name: grilling
description: Interview the user relentlessly about a plan or design. Use when the user wants to stress-test a plan before building, mentions "grill", "stress-test my plan", "poke holes in this", or when another skill needs a structured design interview.
tags: [productivity, design, interview]
audience: Software engineers and developers using Claude Code
source: mattpocock
---

# Grilling

A relentless interview that walks down every branch of a plan's design tree until every dependency is resolved.

## Steps

### Step 1 — Interview relentlessly

Interview the user about every aspect of the plan or design. Walk down each branch of the design tree, resolving dependencies between decisions one at a time. For each question, provide your recommended answer.

Ask one question at a time, waiting for feedback before continuing. If a question can be answered by exploring the codebase, explore it instead of asking.

Keep going until every major branch is resolved and the user has no outstanding uncertainty.

## Guardrails

- Never ask multiple questions at once — one at a time, every time.
- Never skip a branch because it seems obvious; surface it and let the user confirm or redirect.

## Output contract

An interrogated plan whose design tree is fully resolved. The skill produces, in the
conversation, an ordered sequence of one-at-a-time questions — each carrying the
agent's recommended answer — walked down every branch until no dependency is left
open. It writes no files itself; a caller such as `grill-with-docs` persists the
decisions.

## Verification

The interview is done when:

- Every major branch of the design tree was surfaced and resolved with the user, and
  the user has no outstanding uncertainty.
- Questions were asked one at a time, never batched.
- Anything answerable from the codebase was explored rather than asked.
