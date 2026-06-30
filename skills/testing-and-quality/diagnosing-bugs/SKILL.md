---
name: diagnosing-bugs
description: Diagnosis loop for hard bugs and performance regressions. Use when the user says "diagnose", "debug this", or reports something broken, throwing, failing, or slow.
tags: [engineering, debugging, testing]
audience: Software engineers and developers using Claude Code
source: mattpocock
standard: upstream-vendored
---

# Diagnosing Bugs

A discipline for hard bugs. Skip phases only when explicitly justified.

When exploring the codebase, read `CONTEXT.md` (if it exists) for a clear mental model of the relevant modules, and check ADRs in the area you're touching.

## Steps

### Step 1 — Build a feedback loop

This is the skill. Everything else is mechanical. If you have a tight pass/fail signal for the bug — one that goes red on this specific bug — you will find the cause. If you don't, no amount of reading code will save you.

Spend disproportionate effort here. Be aggressive. Be creative. Refuse to give up.

Try these approaches in roughly this order:

1. Failing test at whatever seam reaches the bug — unit, integration, e2e.
2. Curl / HTTP script against a running dev server.
3. CLI invocation with a fixture input, diffing stdout against a known-good snapshot.
4. Headless browser script (Playwright / Puppeteer) — drives the UI, asserts on DOM/console/network.
5. Replay a captured trace — save a real network request or payload to disk and replay it in isolation.
6. Throwaway harness — minimal subset of the system that exercises the bug code path.
7. Property / fuzz loop — if the bug is "sometimes wrong output", run 1000 random inputs.
8. Bisection harness — automate "boot at state X, check, repeat" so you can `git bisect run` it.
9. Differential loop — same input through old-version vs new-version, diff outputs.
10. HITL bash script — last resort, if a human must click.

Once you have a loop, tighten it: make it faster, make the signal sharper, make it deterministic.

Phase 1 is done when you can name one command you have already run that is red-capable, deterministic, fast, and agent-runnable. If you catch yourself reading code to build a theory before this command exists, stop — that is the exact failure this skill prevents.

### Step 2 — Reproduce and minimise

Run the loop and watch it go red.

Confirm the failure matches what the user described — not a different failure nearby. Shrink the repro to the smallest scenario that still goes red. Cut inputs, callers, config, and steps one at a time, re-running after each cut.

Do not proceed until the bug is reproduced and the repro is minimised.

### Step 3 — Hypothesise

Generate 3–5 ranked hypotheses before testing any of them. Each must be falsifiable:

> "If X is the cause, then changing Y will make the bug disappear / changing Z will make it worse."

If you cannot state the prediction, the hypothesis is a vibe — discard or sharpen it.

Show the ranked list to the user before testing. They often have domain knowledge that re-ranks instantly. Don't block on a response — proceed with your ranking if the user is not available.

### Step 4 — Instrument

Each probe must map to a specific prediction from Step 3. Change one variable at a time.

Tool preference: debugger or REPL first; targeted logs at hypothesis-distinguishing boundaries second. Never "log everything and grep."

Tag every debug log with a unique prefix (e.g. `[DEBUG-a4f2]`). Cleanup at the end is a single grep.

For performance regressions: establish a baseline measurement first, then bisect. Measure before fixing.

### Step 5 — Fix and write the regression test

Write the regression test before the fix — but only when a correct seam exists. A correct seam is one where the test exercises the real bug pattern as it occurs at the call site.

If no correct seam exists, that itself is the finding — note it and flag the architectural issue.

If a correct seam exists:
1. Turn the minimised repro into a failing test at that seam.
2. Watch it fail.
3. Apply the fix.
4. Watch it pass.
5. Re-run the Phase 1 feedback loop against the original scenario.

### Step 6 — Clean up and write a post-mortem

Required before declaring done:

- Original repro no longer reproduces (re-run the Phase 1 loop).
- Regression test passes, or absence of a correct seam is documented.
- All `[DEBUG-...]` instrumentation removed (`grep` the prefix).
- Throwaway prototypes deleted.
- The correct hypothesis is stated in the commit or PR message.

Then ask: what would have prevented this bug? If the answer involves architectural change, hand off to `/improve-codebase-architecture` with the specifics — after the fix is in, not before.

## Guardrails

- Never move to Step 2 without a red-capable, deterministic, agent-runnable feedback loop in hand.
- Never skip the minimisation step — it is not optional.
- Never write the regression test after the fix; write it first.
- Never leave `[DEBUG-...]` logs in the codebase — grep and remove them before closing.
