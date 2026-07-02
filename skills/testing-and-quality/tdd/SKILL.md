---
name: tdd
description: Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions "red-green-refactor", "TDD", "write tests first", or wants integration tests written before implementation.
tags: [engineering, testing, workflow]
audience: Software engineers and developers using Claude Code
source: mattpocock
---

# Test-Driven Development

Red-green-refactor, one behavior at a time.

Tests should verify behavior through public interfaces, not implementation details. Code can change entirely; tests should not.

See [references/tests.md](references/tests.md) for examples and [references/mocking.md](references/mocking.md) for mocking guidelines.

## Steps

### Step 1 — Plan

Before writing any code, read `CONTEXT.md` (if it exists) so test names and interface vocabulary match the project's domain language. Respect ADRs in the area you're touching.

Confirm with the user:
- What interface changes are needed?
- Which behaviors to test (prioritize — you can't test everything)?
- Which behaviors are critical paths versus nice-to-have?

Identify opportunities for deep modules (small interface, deep implementation). Run `/codebase-design` for the vocabulary and testability checks if needed.

List the behaviors to test in terms of what the system does, not how. Get user approval on the plan before writing a single line.

### Step 2 — Write the tracer bullet

Write one test that confirms one thing about the system:

```
RED:   Write test for first behavior → test fails
GREEN: Write minimal code to pass → test passes
```

This is your tracer bullet — it proves the path works end-to-end.

### Step 3 — Incremental loop

For each remaining behavior:

```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:
- One test at a time.
- Only enough code to pass the current test.
- Do not anticipate future tests.
- Keep tests focused on observable behavior, not implementation.

### Step 4 — Refactor

After all tests pass, look for refactor candidates per [references/refactoring.md](references/refactoring.md):
- Extract duplication.
- Deepen modules — move complexity behind simple interfaces.
- Run tests after each refactor step.

Never refactor while red. Get to green first.

## Guardrails

- Never write all tests before any implementation (horizontal slicing).
- Never test private methods or internal collaborators — test through public interfaces only.
- Never refactor while a test is red.
- Never write the next test before the current one is green.

## Output contract

Working code built test-first, one behavior at a time. The run produces an approved
behavior-to-test plan stated as what the system does, a tracer bullet that proves the
path end-to-end, a test per behavior that was red before any implementation, the
minimal code that turned each test green, and a refactor pass performed only while
green. Tests verify behavior through public interfaces, so the implementation can
change entirely without changing them.

## Verification

The work is done when:

- Every planned behavior has a passing test that was written and seen to fail before
  its implementation existed.
- All tests exercise public interfaces only — no private methods or internal
  collaborators — and no production code exists beyond what a test required.
- The full suite is green after the final refactor, and each refactor step was run
  against green.
