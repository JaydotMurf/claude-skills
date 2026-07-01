---
name: codebase-design
description: Shared vocabulary for designing deep modules. Use when the user wants to design or improve a module's interface, find deepening opportunities, decide where a seam goes, make code more testable or AI-navigable, or when another skill needs the deep-module vocabulary.
tags: [engineering, architecture, design]
audience: Software engineers and developers using Claude Code
source: mattpocock
---

# Codebase Design

Design deep modules: a lot of behaviour behind a small interface, placed at a clean seam, testable through that interface. Use this language and these principles wherever code is being designed or restructured. The aim is Leverage for callers, Locality for maintainers, and testability for everyone.

## Steps

### Step 1 — Load and apply the reference

Use the vocabulary and principles below throughout the session. Do not substitute alternate terms — consistent language is the whole point.

Deeper reference material:
- Deepening a cluster given its dependencies — see [references/DEEPENING.md](references/DEEPENING.md).
- Exploring alternative interfaces — see [references/DESIGN-IT-TWICE.md](references/DESIGN-IT-TWICE.md).

## Glossary

Use these terms exactly — don't substitute "component," "service," "API," or "boundary." Consistent language is the whole point.

Module — anything with an interface and an implementation. Deliberately scale-agnostic: a function, class, package, or tier-spanning slice.

Interface — everything a caller must know to use the module correctly: the type signature, but also invariants, ordering constraints, error modes, required configuration, and performance characteristics.

Implementation — what's inside a module, its body of code. Distinct from Adapter: a thing can be a small adapter with a large implementation (a Postgres repo) or a large adapter with a small implementation (an in-memory fake).

Depth — Leverage at the interface: the amount of behaviour a caller can exercise per unit of interface they have to learn. A module is deep when a large amount of behaviour sits behind a small interface, shallow when the interface is nearly as complex as the implementation.

Seam _(Michael Feathers)_ — a place where you can alter behaviour without editing in that place; the location at which a module's interface lives.

Adapter — a concrete thing that satisfies an interface at a seam. Describes role (what slot it fills), not substance (what's inside).

Leverage — what callers get from depth: more capability per unit of interface they learn.

Locality — what maintainers get from depth: change, bugs, knowledge, and verification concentrate in one place rather than spreading across callers.

## Deep vs shallow

Deep module = small interface + lots of implementation:

```
┌─────────────────────┐
│   Small Interface   │  ← Few methods, simple params
├─────────────────────┤
│                     │
│  Deep Implementation│  ← Complex logic hidden
│                     │
└─────────────────────┘
```

Shallow module = large interface + little implementation (avoid):

```
┌─────────────────────────────────┐
│       Large Interface           │  ← Many methods, complex params
├─────────────────────────────────┤
│  Thin Implementation            │  ← Just passes through
└─────────────────────────────────┘
```

When designing an interface, ask:
- Can I reduce the number of methods?
- Can I simplify the parameters?
- Can I hide more complexity inside?

## Principles

- Depth is a property of the interface, not the implementation. A deep module can be internally composed of small, mockable, swappable parts — they just aren't part of the interface.
- The deletion test: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- The interface is the test surface. Callers and tests cross the same seam. If you want to test past the interface, the module is probably the wrong shape.
- One adapter means a hypothetical seam. Two adapters means a real one. Don't introduce a seam unless something actually varies across it.

## Designing for testability

1. Accept dependencies, don't create them.
2. Return results, don't produce side effects.
3. Small surface area — fewer methods, fewer tests needed.

## Relationships

- A Module has exactly one Interface.
- Depth is a property of a Module, measured against its Interface.
- A Seam is where a Module's Interface lives.
- An Adapter sits at a Seam and satisfies the Interface.
- Depth produces Leverage for callers and Locality for maintainers.

## Rejected framings

- "Interface" as only the TypeScript `interface` keyword or class public methods: too narrow — interface here includes every fact a caller must know.
- "Boundary": overloaded with DDD's bounded context. Say seam or interface.

## Guardrails

- Never substitute "component", "service", "API", or "boundary" for the vocabulary defined in the Glossary above.
- Never introduce a seam when only one adapter exists — wait until something actually varies.

## Output contract

Applying this skill produces a design stated in the Glossary's vocabulary rather than prose about components or services. Concretely:

- Each unit under design is named as a Module with its single Interface written out — the full set of facts a caller must know, not just the type signature.
- Each Module carries a Depth judgement against that Interface, either deep or shallow, with the reasoning that placed it there.
- Every proposed Seam names the Adapters that justify it, and each deepening opportunity is stated as a specific move: methods to remove, parameters to simplify, or complexity to hide.

## Verification

The design is done when the evidence below holds:

- Every design term used resolves to an entry in the Glossary, and none of the banned substitutes — component, service, API, boundary — stands in its place.
- No Seam is introduced unless at least two real Adapters vary across it; a single hypothetical adapter is not enough.
- Each Module named passes the deletion test: removing it would scatter complexity across its callers rather than make complexity vanish.
- `scripts/check.sh` passes for this file, confirming the Output contract and Verification sections are present and non-empty and the writing rules hold.
