---
name: minimalist-editorial
description: Sub-skill of frontend-taste for minimalist and editorial UI — content-forward pages, essays, reading experiences, and documentation. Applies on top of the frontend-taste core rules. Use when the task is a reading-first or content-first interface.
tags: [frontend, design, editorial, minimalist, web-publishing-and-frontend]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Minimalist / Editorial UI

A sub-skill of [frontend-taste](../SKILL.md). The core rules still apply; this layers the specifics for content-forward design where the words are the interface.

## When to use this skill

Use it, routed from frontend-taste, when the task is reading-first: an essay or article page, documentation, a content marketing post, a manifesto or landing page whose substance is prose. Do not use it for data-dense dashboards (use `data-dense-dashboard`) or conversion-driven launch pages with heavy visual selling (use `premium-marketing`).

## Steps

### Step 1 — Set the reading column

Fix a single measure of roughly 60–75 characters and center the content in it. Everything else (headings, pull quotes, figures) hangs off that column. Completion: body text holds a comfortable measure at the target viewport.

### Step 2 — Build the type hierarchy first

Set the type scale before anything else: body size, the heading levels above it, and small text below. Use one text family, optionally one display family for headings. Hierarchy comes from size, weight, and space, not from color or rules. Completion: a reader can scan the page structure from type alone.

### Step 3 — Let whitespace carry the rhythm

Use vertical space to separate sections and group related blocks. Resist boxes, cards, and borders; an editorial page earns calm from space, not containers. Completion: structure reads without a single box.

### Step 4 — Restrain to near-monochrome plus one accent

Black or near-black text on an off-white or white background, with one accent reserved for links and the single primary action. No decorative color. Completion: the palette is neutral plus exactly one accent.

### Step 5 — Run the frontend-taste verification loop

Screenshot, inspect against measure, hierarchy, and calm, fix the weakest, repeat. Completion: the loop's last pass finds nothing weak.

## Guardrails

- Never widen the reading measure past roughly 75 characters or fill the viewport edge to edge with text; the column is the design.
- Never add cards, borders, or decorative color to manufacture structure that space and type should provide.

## Output contract

A content-forward page built on a single reading column with a clear type hierarchy, near-monochrome palette plus one accent, structure from whitespace, and an inspected verification screenshot.

## Verification standard

Do not call it done until: the measure sits in the 60–75 character range, hierarchy is legible from type alone, no boxes were used to fake structure, the palette is neutral plus one accent, and the frontend-taste loop ran with an inspected screenshot.
