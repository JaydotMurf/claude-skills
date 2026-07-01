---
name: html-artifacts
description: Render dense or visual output (plans, reports, research explainers, review summaries, comparisons, diagrams, dashboards) as a single self-contained HTML file in a consistent house style, instead of a long chat response. Use whenever output would be dense, visual, interactive, or worth keeping or sharing. Other skills that need a polished visual deliverable produce it through this.
tags: [html, artifacts, reporting, core-infrastructure]
audience: engineers, operators, and solo builders
source: open-skills
---

# HTML Artifacts

When output is dense, visual, or worth keeping, a long chat message is the wrong container. This skill renders it as one self-contained HTML file in a consistent house style: easy to keep, send, and open, and guaranteed to work offline.

## When to use this skill

Offer or produce an artifact when:

- The output is dense or structured: a report, a research explainer, a review summary.
- The output is visual or comparative: a comparison table, a timeline, a diagram, a dashboard.
- The output is interactive or worth keeping and sharing.

Do not use it for a short, plain answer that reads fine inline. An artifact for two sentences is overhead.

## Saved defaults

- Output directory: `~/Documents/artifacts/`, filenames `YYYY-MM-DD-<slug>.html`.
- House style: the tokens and layout patterns in `template.html`, the single source of the look.
- Default appearance: light, with an automatic dark variant via `prefers-color-scheme`. No API key required.

## Steps

### Step 1 — Pick the layout pattern

Choose the pattern that fits the content: report, comparison table, timeline, diagram, or dashboard. Most artifacts combine a report header with one or two of the others.

### Step 2 — Copy the template and fill it

Copy `template.html` to the output directory under a dated slug name, keep its `<style>` block unchanged so the house style is preserved, and replace the demo `<body>` with the real content using the chosen patterns. Keep everything in the one file: inline CSS and JS only, no external dependencies.

### Step 3 — Check it is self-contained

Run the checker:

```bash
./check.sh ~/Documents/artifacts/your-artifact.html
```

It fails if the file pulls any external resource needed to render. Fix anything it flags before continuing.

### Step 4 — Open it and confirm it renders

Open the artifact and confirm it actually renders before declaring it done:

```bash
./check.sh ~/Documents/artifacts/your-artifact.html --open
```

Completion: the checker passes and you have seen the artifact render.

## House style tokens

Defined once at the top of `template.html` and inlined into every artifact:

- Type: system sans stack for body, monospace for code.
- Color: light by default (`--bg`, `--surface`, `--text`, `--muted`, `--border`, `--accent` blue), with a `prefers-color-scheme: dark` override.
- Spacing and shape: a `--space-1` through `--space-6` scale, `--radius`, and a `--measure` reading width.

Change the look in one place by editing the tokens; every new artifact inherits it. Existing artifacts keep their own inlined copy, which is what makes them portable.

## Layout patterns

`template.html` carries a labelled, working example of each:

- Report: a header with badge, title, and lead, followed by sections.
- Comparison table: a styled table with an uppercase header row.
- Timeline: a vertical list with accent markers and monospace labels.
- Dashboard: a responsive grid of stat cards.
- Diagram: a horizontal flow of labelled nodes connected by arrows.

## For other skills

If your skill produces a polished visual deliverable (a plan, a report, a comparison), render it through html-artifacts so it carries the same house style and the same self-contained guarantee. Do not hand-roll one-off HTML elsewhere.

## Guardrails

- Never reference an external resource needed to render: no remote scripts, stylesheets, fonts, or images. The artifact must work fully offline.
- Never split an artifact across multiple files; it is always one self-contained HTML file.
- Never declare an artifact done without running the checker and opening it to confirm it renders.

## Output contract

A single self-contained `.html` file in the output directory (default `~/Documents/artifacts/`), named `YYYY-MM-DD-<slug>.html`, carrying its own inline style and passing the self-contained check.

## Verification standard

Do not call the task done until: `check.sh` reports the file self-contained and offline-safe, and the artifact has been opened and confirmed to render. The skill ships a worked example, `example.html`, a self-contained setup summary of this skill that passes the check.
