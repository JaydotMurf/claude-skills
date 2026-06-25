---
name: to-prd
description: Turn the current conversation into a PRD and publish it to the project issue tracker — no interview, just synthesis of what has already been discussed. Use when the user explicitly runs /to-prd or asks to "write up the PRD" from the current conversation.
tags: [engineering, planning, documentation]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
---

# To PRD

Synthesize the current conversation into a structured PRD and publish it to the issue tracker. Do not interview the user — work from what is already in context.

The issue tracker and triage label vocabulary must be configured — run `/setup-skills` if not already done.

## Steps

### Step 1 — Explore the codebase

Explore the repo to understand the current state of the code, if you haven't already. Use the project's domain glossary vocabulary throughout the PRD, and respect any ADRs in the area you're touching.

### Step 2 — Identify test seams

Sketch out the seams at which you will test the feature. Prefer existing seams over new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can — the fewer seams across the codebase, the better. The ideal number is one.

Confirm with the user that these seams match their expectations before writing the PRD.

### Step 3 — Write and publish the PRD

Write the PRD using the template below, then publish it to the issue tracker. Apply the `ready-for-agent` triage label — no additional triage needed.

```
## Problem Statement

The problem the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A numbered list of user stories. Each in the format:

1. As a <actor>, I want <feature>, so that <benefit>

Cover all aspects of the feature — be extensive.

## Implementation Decisions

A list of implementation decisions: modules to build or modify, interface changes, architectural decisions, schema changes, API contracts, specific interactions.

Do not include specific file paths or code snippets. Exception: prototype-derived snippets that encode a decision more precisely than prose can — inline them and note they came from a prototype.

## Testing Decisions

Which modules will be tested, what makes a good test (external behavior only, not implementation details), and prior art for the tests in the codebase.

## Out of Scope

What is explicitly not being addressed in this PRD.

## Further Notes

Any additional context about the feature.
```

## Guardrails

- Never interview the user — synthesize from the current conversation only.
- Never include specific file paths or code snippets in the PRD body, except for decision-encoding prototype extracts.
- Never close or modify any existing parent issue.
