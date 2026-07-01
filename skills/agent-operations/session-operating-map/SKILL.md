---
name: session-operating-map
description: Set up and maintain a single repo-local operating map for projects where multiple agent sessions run in parallel — one lane per concern, each with its objective, owning session, current state, and blockers. Updated on meaningful state changes (start, block, handoff, done), not as a journal; finished lanes archived with a one-line outcome and their lessons promoted into docs or skills. Trigger when the user starts parallel workstreams, asks what's in flight, or asks to set up coordination for a repo.
tags: [agent-operations, coordination, parallel-sessions, operating-map]
audience: engineers, operators, and solo builders
source: open-skills
---

# Session Operating Map

When several agent sessions work the same repo at once, the failure mode is two lanes editing the same files, a blocked lane nobody notices, and a decision made twice. The operating map is the single repo-local source of truth that prevents this: who owns what, where each lane stands, and what is blocking it. Every session reads it before starting and updates it when its own state meaningfully changes.

## When to use this skill

Invoke it when:

- The user starts parallel workstreams in a project, or is about to (for example before delegating with visible-delegation or splitting work across worktrees).
- The user asks what is in flight, what each session is doing, or where things stand.
- The user asks you to set up coordination, lane tracking, or a status doc for a repo.

Do not invoke it for a project where only one session ever runs at a time, for tracking a single linear task (a plan or todo list fits that better), or as a running activity log — the map records state, not history. If there is nothing parallel to coordinate, this skill is overhead.

## The map file

The map is a single repo-local document. Default location `docs/operating-map.md`. It holds two parts: active lanes and a done section.

Each active lane is one entry with five fields:

- Lane: a short name that makes the concern obvious (for example `auth-refactor`, `ci-fix`).
- Objective: one line on what this lane is trying to accomplish.
- Owner: which session or worktree owns it.
- State: where it stands right now (for example active, blocked, in review, handing off).
- Blockers: what is stopping it, or none.

A minimal template:

```markdown
# Operating Map

## Active lanes

### auth-refactor
- Objective: move session auth onto the new token service
- Owner: session A (worktree build/auth)
- State: active
- Blockers: none

## Done
- ci-fix — flaky test quarantined, pipeline green (2026-06-29)
```

## Steps

### Step 1 — Read the existing map first

If `docs/operating-map.md` exists, read it before doing anything else. Any session joining the project reads the map before starting work, so it knows which lanes exist, who owns what, and what is blocked. Completion: you know the current state of every active lane, or you have confirmed no map exists yet.

### Step 2 — Create the map if it does not exist

If there is no map, create `docs/operating-map.md` with the structure above: an Active lanes section and a Done section. Completion: the map file exists with both sections.

### Step 3 — Define lanes, one per concern

Carve the parallel work into lanes where each lane owns exactly one concern and is named so its purpose is obvious from the name alone. Do not lump two concerns into one lane or split one concern across two. Completion: every in-flight concern maps to exactly one clearly named lane.

### Step 4 — Populate each lane with its real state

Fill in objective, owner, state, and blockers for each active lane from what is actually happening, not what was planned. Completion: every active lane has all five fields filled from reality.

### Step 5 — Update only on meaningful state changes

Update a lane's entry when its state meaningfully changes — it starts, it blocks, it hands off, it finishes — not on every action. The map is a current-state document, not a journal; routine progress inside a lane does not earn an edit. Completion: the map reflects the current state of every lane and no lane entry is stale.

### Step 6 — Archive finished lanes and promote their lessons

When a lane finishes, move it from Active lanes to the Done section with a one-line outcome and a date. If the lane produced a lesson worth keeping — a reusable pattern, a gotcha, a decision — promote it into the project's docs or into a skill rather than letting it die in the map. The map keeps the outcome; the durable knowledge goes somewhere durable. Completion: finished lanes are in Done with a one-line outcome, and any keepable lesson has been promoted out of the map.

## Guardrails

- Never run more than one operating map per repo; the map's value is being the single source of truth, and a second map destroys that.
- Never use the map as an activity journal; it records current lane state, and an entry changes only when the lane's state meaningfully changes.
- Never let a finished lane's lesson die in the map; promote reusable knowledge into docs or a skill before archiving the lane.
- Never start work in a parallel project without reading the map first.

## Output contract

A single repo-local operating map (default `docs/operating-map.md`) with an Active lanes section — one lane per concern, each carrying name, objective, owner, state, and blockers — and a Done section where finished lanes hold a one-line dated outcome, with their durable lessons promoted into docs or skills.

## Verification standard

Do not call the task done until: exactly one map exists for the repo, every in-flight concern is a single clearly named lane with all five fields filled from reality, finished lanes are archived in Done with a one-line dated outcome, and any keepable lesson has been promoted out of the map. Acceptance test: set up the map for the current project and populate it with what is actually in flight. Build-time note (2026-06-29): the live acceptance run was deferred because `docs/` is owned by a different worktree in this build and is out of this worktree's write scope; the skill creates `docs/operating-map.md` on first real use in a project where that path is writable.
