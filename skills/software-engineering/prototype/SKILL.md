---
name: prototype
description: Build a throwaway prototype to answer a design question — a runnable terminal app for state/logic questions, or several radically different UI variations for visual questions. Use when the user explicitly runs /prototype or wants to answer "what should this look like?" or "does this logic feel right?" with running code.
tags: [engineering, prototyping, design]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
source: mattpocock
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

1. Throwaway from day one. Locate the prototype close to where it will actually be used (next to the module or page it's prototyping for) so context is obvious — but name it so a casual reader can see it's a prototype. For throwaway UI routes, obey whatever routing convention the project already uses; don't invent a new top-level structure.
2. One command to run. Whatever the project's existing task runner supports — `pnpm <name>`, `python <path>`, etc.
3. No persistence by default. State lives in memory. If the question explicitly involves a database, hit a scratch DB or a local file with a clear "PROTOTYPE — wipe me" name.
4. Skip the polish. No tests, no error handling beyond what makes the prototype runnable, no abstractions.
5. Surface the state. After every action (logic) or on every variant switch (UI), print or render the full relevant state.

### Step 3 — Capture the answer and the prototype

A finished prototype leaves two things worth keeping: the decision it validated and the prototype itself as a primary source. Fold the validated decision into the real code, then commit the prototype to a throwaway branch, out of main, and leave a context pointer to that branch on the implementation issue. Capture the verdict too — the answer and the question it settled — in the issue or a commit. The main branch keeps only the validated decision.

## Guardrails

- Never treat prototype code as production code — mark it as throwaway from day one.
- Never add persistence by default; state lives in memory unless the question is explicitly about persistence.
- Never leave prototype code in the main branch — main keeps only the validated decision; the prototype itself lives on a throwaway branch with a captured verdict and a pointer from the implementation issue.

## Output contract

A throwaway prototype that answers exactly one design question — an interactive terminal
app for a logic or state question, or several radically different UI variations on one
route for a visual question — runnable by a single command, with no persistence or
polish, surfacing the full relevant state after each action or variant switch. Once it
has answered, the validated decision is folded into the real code, the prototype is
committed to a throwaway branch as a primary source with a context pointer on the
implementation issue, and the verdict — the answer and the question it settled — is
captured in the issue or a commit.

## Verification

The prototype is done when:

- The branch matched the question (logic app for state/logic, UI variations for a visual
  question), stated as an assumption at the top when the question was ambiguous.
- The prototype answered its question and the verdict — the answer plus the question it
  settled — was captured in the implementation issue or a commit.
- The validated decision was folded into the real code, and the prototype was committed
  to a throwaway branch, out of main, with a context pointer to that branch on the
  implementation issue.
- No prototype code remains in the main branch.
