---
name: ship-a-page-you-can-trust
description: Build a page well, take it live, verify the live page with instruments rather than vibes, and bank what QA learned so the next deploy verifies in minutes.
tags: [frontend, publishing, testing, qa]
audience: frontend engineers, operators, and solo builders
---

# Ship a Page You Can Trust

The difference between shipping a page and shipping a page you would bet on. This runbook builds the page to a taste standard, takes it live, then verifies the live result with instruments and writes the testing knowledge back into the repo.

## Outcome

A live page built to the taste standard, verified on the live URL across breakpoints with screenshots and Core Web Vitals, and a repo testing-runbook entry that lets the next deploy verify the same page in minutes.

## Skills it calls

1. `web-publishing-and-frontend/frontend-taste` — takes the page brief; produces a built or restyled UI satisfying the layout, typography, and color rules, plus an inspected screenshot from its verification loop. Hands the built page to the next step.
2. `web-publishing-and-frontend/site-publisher` — takes the built page; ships it to a live URL with a clean slug, OG image, and share metadata. Hands the live URL to the next step.
3. `testing-and-quality/browser-qa` — takes the live URL; drives it through the Chrome DevTools MCP server and produces a Checked / Passed / Failed report where every line carries evidence (screenshots across breakpoints, Core Web Vitals against thresholds, console and network checks). Hands the page-specific testing facts to the next step.
4. `testing-and-quality/testing-runbook-creator` — takes those facts; writes them into `docs/testing-runbook.md` as an entry carrying all six fields (name, how to test, safe vs. destructive actions, setup and seed, cleanup, exact verification commands with expected output).

## Verification

- The taste step produced at least one inspected screenshot and named the sub-skill it used.
- The live URL resolves and matches site conventions.
- The browser-QA report carries evidence on every line, with reproduction steps on each failure, gathered against the live page.
- `docs/testing-runbook.md` contains a new entry for this page with all six fields populated from live observation.
