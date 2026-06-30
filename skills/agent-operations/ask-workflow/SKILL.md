---
name: ask-workflow
description: Ask which skill or flow fits your situation. A router over the user-invoked skills in this library. Use when you can't remember which skill to reach for, or want to understand which flow applies to your current work.
tags: [productivity, workflow, navigation]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
source: mattpocock
standard: upstream-vendored
---

# Ask Workflow

You don't remember every skill, so ask.

A flow is a path through the skills. Most paths run along one main flow, and two on-ramps merge onto it. Everything else is standalone.

## Steps

### Step 1 — Find the right skill or flow

Read the map below and direct the user to the skill or flow that matches their situation.

## The main flow: idea → ship

The route most work travels. You have an idea and want it built.

1. `/grill-with-docs` — sharpen the idea by interview. Start here when you have a codebase: it's stateful, retaining what it learns in `CONTEXT.md` and ADRs. (No codebase? Use `/grill-me` — see Standalone.)
2. Branch — can you settle every question in conversation? If a question needs a runnable answer (state, business logic, a UI you have to see), detour through a prototype, bridged by `/handoff` in both directions:
   - `/handoff` out, then open a fresh session against that file.
   - `/prototype` to answer the question with throwaway code.
   - `/handoff` back what you learned, and reference it from the original idea thread.
3. Branch — is this a multi-session build?
   - Yes → `/to-prd` (turn the thread into a PRD) → `/to-issues` (split the PRD into independently-grabbable issues). Clear context between each issue: start a fresh session per issue.
   - No → implement right here, in the same context window.

Keep steps 1–3 in one unbroken context window — don't compact or clear until after `/to-issues` — so the grilling, PRD, and issues all build on the same thinking.

## On-ramps

A starting situation that generates work, then merges onto the main flow.

- Bugs and requests piling up → `/triage`. It moves issues through triage roles and produces agent-ready issues. Triage is only for issues you didn't create — bug reports, incoming feature requests, anything that arrives raw. Issues that `/to-issues` produced are already agent-ready.

## Codebase health

Not feature work — upkeep.

- `/improve-codebase-architecture` — run whenever you have a spare moment to keep the codebase good for agents to operate in. It surfaces deepening opportunities; picking one generates an idea you can take into the main flow at `/grill-with-docs`.

## Crossing sessions

- `/handoff` — when a thread is full or you need to branch off, this compacts the conversation into a markdown file. Open a new session and reference that file to carry context across. Use it when you want a fresh session but need the current conversation preserved.
- `/compact` (built-in) — stay in the same conversation, letting earlier turns be summarised. Use at intentional breaks between phases, not mid-phase.

## Standalone

Off the main flow entirely.

- `/grill-me` — the same relentless interview as `/grill-with-docs`, but for when you have no codebase. Stateless.
- `/teach` — learn a concept over multiple sessions, using the current directory as a stateful workspace.
- `/writing-great-skills` — reference for writing and editing skills well.

## Precondition

`/setup-skills` — run before your first engineering flow to configure the issue tracker, triage labels, and doc layout the other skills assume.

## Guardrails

- Never direct the user to run `/triage` on issues that `/to-issues` created — those are already `ready-for-agent`.
- Never suggest both `/grill-me` and `/grill-with-docs` for the same situation — pick the one that matches whether a codebase is present.
