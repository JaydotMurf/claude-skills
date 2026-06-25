---
name: prototype
description: Build a throwaway prototype to answer a design question — a runnable terminal app for state/logic questions, or several radically different UI variations for visual questions. Use when the user explicitly runs /prototype or wants to answer "what should this look like?" or "does this logic feel right?" with running code.
tags: [engineering, prototyping, design]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
---

# Prototype

A prototype is throwaway code that answers a question. The question decides the shape.

## Steps

### Step 1 — Pick a branch

Identify which question is being answered — from the user's prompt, the surrounding code, or by asking if the user is around:

- "Does this logic / state model feel right?" → See [references/LOGIC.md](references/LOGIC.md). Build a tiny interactive terminal app that pushes the state machine through cases that are hard to reason about on paper.
- "What should this look like?" → See [references/UI.md](references/UI.md). Generate several radically different UI variations on a single route, switchable via a URL search param and a floating bottom bar.

The two branches produce very different artifacts — getting this wrong wastes the whole prototype. If the question is genuinely ambiguous and the user isn't reachable, default to whichever branch better matches the surrounding code (backend module → logic; page or component → UI) and state the assumption at the top of the prototype.

### Step 2 — Build the prototype

Apply these rules regardless of which branch you chose:

1. Throwaway from day one. Locate the prototype close to where it will actually be used (next to the module or page it's prototyping for) so context is obvious — but name it so a casual reader can see it's a prototype.
2. One command to run. Whatever the project's existing task runner supports — `pnpm <name>`, `python <path>`, etc.
3. No persistence by default. State lives in memory. If the question explicitly involves a database, hit a scratch DB or a local file with a clear "PROTOTYPE — wipe me" name.
4. Skip the polish. No tests, no error handling beyond what makes the prototype runnable, no abstractions.
5. Surface the state. After every action (logic) or on every variant switch (UI), print or render the full relevant state.

### Step 3 — Capture the answer

The answer is the only thing worth keeping from a prototype. When the prototype has answered its question, capture the verdict somewhere durable (commit message, ADR, issue, or a `NOTES.md` next to the prototype), then delete it or fold the validated decision into the real code.

## Guardrails

- Never treat prototype code as production code — mark it as throwaway from day one.
- Never add persistence by default; state lives in memory unless the question is explicitly about persistence.
- Never leave a prototype in the repo without a captured verdict — either capture the answer and delete it, or absorb the validated decision into the real code.
