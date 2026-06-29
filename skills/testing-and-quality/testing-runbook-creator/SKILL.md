---
name: testing-runbook-creator
description: Whenever you test, verify, smoke-test, QA, or debug anything in a repo, capture what you learned as a repo-local runbook entry so the next session does not rediscover it. Maintains docs/testing-runbook.md as a living recipe book — read it before testing, follow the existing recipe, and fix it in the same session when reality differs. Use on any testing or verification activity in a repo, not only when the user says "runbook".
tags: [testing-and-quality, testing, verification, runbook, memory, repo-local]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Testing Runbook Creator

Testing knowledge evaporates between sessions. An agent works out how to seed the database, which command proves the checkout flow, and which button wipes production data — then the session ends and the next agent starts from zero. This skill turns every testing or verification activity into a durable repo-local entry, so the recipe is written down once and followed forever after.

## When to use this skill

Invoke it on any testing or verification activity in a repo:

- Smoke-testing, QA-ing, or manually exercising a page, workflow, feature, endpoint, or command.
- Running or writing tests, reproducing a bug, or confirming a fix works.
- Any moment you learn how to exercise part of the system — what to run, what to set up first, what is safe to touch, what to expect.

The trigger is the activity, not the word. You do not wait for the user to say "runbook". If you are about to verify something, this skill is already active.

Do not invoke it for pure code authoring with no verification step, for one-off shell commands unrelated to exercising the system (a `git log`, an `ls`), or for reading code to answer a question. If nothing is being tested or verified, there is nothing to record.

## Runbook location and format

The runbook lives at `docs/testing-runbook.md` in the repo under test. If the repo already keeps testing notes elsewhere (a `TESTING.md`, a `docs/qa/` directory), use that instead of creating a competing file; match the repo, do not fight it. Recorded assumption (build time): `docs/testing-runbook.md` is the default when the repo has no existing convention.

Each entry covers one page, workflow, or feature and carries these fields in this order:

1. Name — the page, workflow, or feature this entry tests.
2. How to test it — the steps in order, concrete enough to follow without guessing.
3. Safe vs. destructive actions — which actions are read-only and which mutate or delete state, called out explicitly so the next agent does not learn the hard way.
4. Setup and seed requirements — what must exist first (running services, env vars, seed data, a test account) and how to get there.
5. Cleanup steps — what to undo afterward so the next run starts clean.
6. Verification commands — the exact commands to run and the expected output, so "it passed" is checkable, not a claim.

## Steps

### Step 1 — Read the runbook before you test

Before exercising anything, open `docs/testing-runbook.md` (or the repo's equivalent) and check whether an entry already covers what you are about to test. If it does, follow that recipe rather than improvising a new one. Completion: you know whether a recipe exists, and if it does you are following it.

### Step 2 — Record setup and seed state as you establish it

As you get the system into a testable state — starting services, setting env vars, seeding data, logging in — write those steps into the entry's setup section while you do them, not from memory afterward. Completion: the setup section reflects exactly what you actually did to make the test possible.

### Step 3 — Test, and record the recipe as you go

Run the workflow. As each step works, capture it: the action, whether it was safe or destructive, the verification command, and its expected output. Record discoveries the moment you make them, not at the end. Completion: the entry's how-to-test, safe/destructive, and verification sections are written from live observation.

### Step 4 — Reconcile the runbook with reality

If an existing entry said something that turned out to be wrong or stale — a command that changed, a step that no longer applies, a destructive action not previously flagged — fix the entry in this same session. Do not leave a known-wrong recipe in place for the next agent to trip over. Completion: no entry you touched contradicts what you just observed.

### Step 5 — Record cleanup and confirm the entry stands alone

Write the cleanup steps, run them, and then reread the entry as if you were a fresh agent: could you follow it with no other context? Fill any gap that would force the next session to rediscover something. Completion: the entry is self-sufficient.

## Guardrails

- Never report a verification as passed without recording the exact command and its expected output in the runbook; an unrecorded pass is a claim, not evidence.
- Never leave a runbook entry that you know contradicts what you just observed; reconcile it in the same session or the runbook becomes a liability.
- Never defer recording to the end of the session; capture each discovery as you make it, because end-of-session memory is where testing knowledge goes to die.
- Never record a destructive action without flagging it as destructive; the cost of that omission lands on the next agent.

## Output contract

One or more entries in `docs/testing-runbook.md` (or the repo's existing testing-notes file), each covering a single page, workflow, or feature, each carrying all six fields — name, how to test, safe vs. destructive actions, setup and seed requirements, cleanup steps, and exact verification commands with expected output — written from live observation during this session.

## Verification standard

Do not call the task done until: the runbook was read before testing began, every entry you wrote or touched carries all six fields, every verification claim has its exact command and expected output recorded, any destructive action is flagged, and any entry that conflicted with reality was fixed this session. Test it by smoke-testing one workflow in a repo the user points to and showing the entry it produced. Build-time note: no target repo was supplied at build time, so the first real invocation against a user repo is the acceptance test.
