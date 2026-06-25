---
name: to-issues
description: Break a plan, spec, or PRD into independently-grabbable issues on the project issue tracker using tracer-bullet vertical slices. Use when the user explicitly runs /to-issues or asks to "break this into issues" or "create issues from the PRD".
tags: [engineering, planning, workflow]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
---

# To Issues

Break a plan into independently-grabbable issues using vertical slices (tracer bullets).

The issue tracker and triage label vocabulary must be configured — run `/setup-skills` if not already done.

## Steps

### Step 1 — Gather context

Work from whatever is already in the conversation. If the user passes an issue reference (number, URL, or path) as an argument, fetch it from the tracker and read its full body and comments.

### Step 2 — Explore the codebase

If you have not already explored the codebase, do so now. Issue titles and descriptions should use the project's domain glossary vocabulary and respect ADRs in the area being touched.

Look for opportunities to prefactor the code before the main work. "Make the change easy, then make the easy change."

### Step 3 — Draft vertical slices

Break the plan into tracer bullet issues. Each issue is a thin vertical slice that cuts through all integration layers end-to-end — not a horizontal slice of one layer.

Rules for vertical slices:
- Each slice delivers a narrow but complete path through every layer (schema, API, UI, tests).
- A completed slice is demoable or verifiable on its own.
- Any prefactoring goes first, as its own slice.

### Step 4 — Quiz the user

Present the proposed breakdown as a numbered list. For each slice show: title, blocked-by dependencies, and which user stories it covers (if the source has them).

Ask:
- Does the granularity feel right (too coarse / too fine)?
- Are the dependency relationships correct?
- Should any slices be merged or split further?

Iterate until the user approves.

### Step 5 — Publish to the issue tracker

For each approved slice, publish a new issue. Use the template below. Issues are considered ready for AFK agents — publish with the `ready-for-agent` label unless instructed otherwise.

Publish in dependency order (blockers first) so you can reference real issue identifiers in the "Blocked by" field.

Issue template:
```
## Parent

Reference to the parent issue (if source was an existing issue; otherwise omit).

## What to build

Concise description of this vertical slice — end-to-end behavior, not layer-by-layer implementation.

Avoid specific file paths or code snippets. Exception: prototype-derived snippets encoding a decision more precisely than prose can.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- Reference to the blocking ticket (if any)

Or "None — can start immediately" if no blockers.
```

## Guardrails

- Never publish issues with horizontal slices — each issue must cut vertically through all integration layers.
- Never close or modify any parent issue.
- Never publish issues out of dependency order.
