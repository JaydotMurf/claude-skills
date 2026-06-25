---
name: domain-modeling
description: Build and sharpen a project's domain model. Use when the user wants to pin down domain terminology, establish a ubiquitous language, record an architectural decision, or when another skill needs to update CONTEXT.md or create ADRs.
tags: [engineering, domain, documentation]
audience: Software engineers and developers using Claude Code
---

# Domain Modeling

Actively build and sharpen the project's domain model as you design. This is the active discipline — challenging terms, inventing edge-case scenarios, and writing the glossary and decisions down the moment they crystallise.

Merely reading `CONTEXT.md` for vocabulary is not this skill. This skill is for when you're changing the model, not just consuming it.

## Steps

### Step 1 — Locate the domain docs

Most repos have a single context:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
```

If a `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts. The map points to where each one lives.

Create files lazily — only when you have something to write. If no `CONTEXT.md` exists, create one when the first term is resolved.

Use the format in [references/CONTEXT-FORMAT.md](references/CONTEXT-FORMAT.md).

### Step 2 — Challenge and sharpen terminology

When the user uses a term that conflicts with the existing language in `CONTEXT.md`, call it out: "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

When the user uses vague or overloaded terms, propose a precise canonical term: "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Step 3 — Test with concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about boundaries between concepts.

### Step 4 — Cross-reference with code

When the user states how something works, check whether the code agrees. Surface contradictions: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

### Step 5 — Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there. Do not batch these. `CONTEXT.md` is a glossary only — no implementation details, no specs, no scratch pad.

### Step 6 — Offer ADRs when all three hold

Only offer to create an ADR when all three are true:
1. Hard to reverse — the cost of changing your mind later is meaningful.
2. Surprising without context — a future reader will wonder "why did they do it this way?"
3. The result of a real trade-off — genuine alternatives existed and you picked one for specific reasons.

If any is missing, skip the ADR. Use the format in [references/ADR-FORMAT.md](references/ADR-FORMAT.md).

## Guardrails

- Never add implementation details to CONTEXT.md — it is a glossary and nothing else.
- Never offer an ADR unless all three conditions hold: hard to reverse, surprising without context, and the result of a real trade-off.
- Never batch CONTEXT.md updates — capture each resolved term immediately.
