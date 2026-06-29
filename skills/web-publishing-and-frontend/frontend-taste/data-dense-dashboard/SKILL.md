---
name: data-dense-dashboard
description: Sub-skill of frontend-taste for data-dense dashboard UI — tables, metrics, admin panels, and any information-heavy interface. Applies on top of the frontend-taste core rules. Use when the task packs a lot of data into a usable screen.
tags: [frontend, design, dashboard, data, tables, web-publishing-and-frontend]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Data-Dense Dashboard UI

A sub-skill of [frontend-taste](../SKILL.md). The core rules still apply; this layers the specifics for getting a lot of information onto one screen without it turning to noise.

## When to use this skill

Use it, routed from frontend-taste, when the task is information-heavy: a dashboard, an admin panel, a data table, a metrics or monitoring view, a settings surface with many fields. Do not use it for reading-first pages (use `minimalist-editorial`) or marketing pages (use `premium-marketing`).

## Steps

### Step 1 — Set density on a tight base unit

Choose a small base spacing unit (for example 4px) and build padding, gaps, and row heights as multiples of it. Density is a deliberate value, not an accident; pick the row height before filling the table. Completion: every gap is a multiple of one base unit.

### Step 2 — Align numbers and establish a scan path

Right-align numeric columns, left-align text, give every column a clear header. Make the primary metric or the primary action visually dominant so the eye lands there first. Completion: a user knows where to look first and numbers line up for comparison.

### Step 3 — Use a muted palette and reserve color for meaning

Keep the chrome neutral and quiet so the data is the loudest thing on screen. Reserve color strictly for semantics: one accent for the primary action, and status colors (success, warning, error) used only for status. Completion: color on screen always means something.

### Step 4 — Make hierarchy survive density

With many elements close together, use weight, subtle dividers, and grouping to keep the structure legible. Avoid heavy borders on every cell; rely on alignment and spacing, add rules only where grouping needs them. Completion: structure is readable despite the density.

### Step 5 — Run the frontend-taste verification loop at real data volume

Screenshot with realistic row counts and long values, not three tidy demo rows. Inspect for overflow, misalignment, and color that has lost its meaning. Fix the weakest, repeat. Completion: the loop's last pass at full volume finds nothing weak.

## Guardrails

- Never verify a dashboard against a handful of clean demo rows; inspect it at realistic data volume with long and edge-case values.
- Never spend color on decoration in a data view; every non-neutral color must carry semantic meaning.

## Output contract

A dense, usable information view built on a tight base unit, with aligned columns, a clear scan path, a muted palette where color means status or action, and a verification screenshot taken at realistic data volume.

## Verification standard

Do not call it done until: spacing is consistent multiples of the base unit, numeric columns align, the primary metric or action is dominant, color is reserved for meaning, and the frontend-taste loop ran on a screenshot at realistic data volume with no remaining weakness.
