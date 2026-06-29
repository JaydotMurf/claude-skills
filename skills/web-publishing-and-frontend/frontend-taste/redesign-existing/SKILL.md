---
name: redesign-existing
description: Sub-skill of frontend-taste for redesigning an existing project's UI without breaking it. Applies the taste rules to live code behind a safety procedure of inventory, incremental change, and before/after verification. Use when improving the look of something that already works.
tags: [frontend, design, redesign, refactor, web-publishing-and-frontend]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Redesigning Existing Projects Without Breaking Them

A sub-skill of [frontend-taste](../SKILL.md). The core rules still apply; this layers a safety procedure for raising the taste of a UI that already exists and already works, without regressing behavior.

## When to use this skill

Use it, routed from frontend-taste, when the task is improving the appearance of an existing, working interface: a restyle, a visual refresh, a design-debt cleanup, adopting the taste rules in a codebase that predates them. Do not use it for greenfield UI (route to the matching build sub-skill) or for changes that alter behavior or data flow rather than appearance.

## Steps

### Step 1 — Capture the before state

Screenshot the existing UI at the viewports you will touch, and note what currently works: layouts, interactions, and flows that must keep working. This is the regression baseline. Completion: a before screenshot and a short list of behavior that must not break.

### Step 2 — Inventory the existing system

Find the existing design tokens, component patterns, and conventions (color variables, spacing scale, typography, shared components). Decide what to keep, what to retire, and where the taste rules conflict with current patterns. Completion: you know the system you are changing.

### Step 3 — Change incrementally, tokens first

Apply the taste rules in small, reviewable steps, starting at the shared layer (tokens, base styles, shared components) so improvements propagate, then page-specific fixes. Avoid a single sweeping rewrite. Completion: changes land in small steps, each independently checkable.

### Step 4 — Verify after each step against the baseline

After each step, screenshot the same viewports and compare against the before state: the look should improve and the behavior from Step 1 must still work. If anything regressed, fix it before the next step. Completion: every step left behavior intact and the look better.

### Step 5 — Run the frontend-taste verification loop on the final result

Inspect the final screenshots against the core layout, type, and color rules, fix the weakest, repeat, and confirm nothing from the baseline behavior list broke. Completion: the loop's last pass is clean and no baseline behavior regressed.

## Guardrails

- Never refactor behavior, data flow, or markup structure beyond what the visual change requires; this skill changes how it looks, not what it does.
- Never apply a sweeping rewrite without a before-state screenshot and a per-step regression check against it.

## Output contract

An existing UI raised to the taste rules through incremental, token-first changes, with a before screenshot, a preserved list of behavior that must keep working, after screenshots per step, and a final verification screenshot — and no behavioral regression.

## Verification standard

Do not call it done until: a before baseline (screenshot plus behavior list) was captured, changes landed incrementally starting from shared tokens, each step verified the look improved and behavior held, and the frontend-taste loop ran on the final result with no remaining weakness and no regression.
