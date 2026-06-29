---
name: page-testing-memory
description: The general process for QA-ing any web page or UI — states, forms, auth boundaries, responsive breakpoints, screenshot evidence — held globally, while every page-specific fact (selectors, routes, test accounts, seed data, cleanup quirks) lives in the repo's testing runbook and never in this skill. Partners with testing-runbook-creator. Use when QA-ing or verifying any web page or UI.
tags: [testing-and-quality, qa, web, ui, responsive, forms, auth, memory]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Page Testing Memory

Page QA has two layers that get tangled. One is the process — the same sequence of checks applies to almost any page. The other is the page's particulars — its routes, its selectors, the test account that can log in, the seed row the table needs. This skill owns the process and only the process. The particulars belong to the repo under test, recorded through the [[testing-runbook-creator]] skill. Keeping the split clean is what lets the process travel to every project while the specifics stay where they are true.

## When to use this skill

Invoke it when QA-ing or verifying any web page or UI:

- Checking that a page renders and behaves correctly after a change.
- Verifying a form, an auth-gated route, or responsive layout.
- Any manual exercise of a rendered web surface where you need a repeatable process.

Do not invoke it for backend-only or API verification with no rendered page, for CLI tools, or for pure visual design judgment — design taste is a separate concern from QA. If there is no page to exercise, this skill has nothing to do.

## The knowledge split

This is the core of the skill and is not optional. State the split explicitly every time:

- Process lives here. The order of checks, the categories of input to try, the breakpoints to test, the demand for screenshot evidence — these are general and stay in this skill.
- Page specifics live in the repo runbook. Selectors, URLs and routes, test account credentials, seed data, cleanup quirks, and any "on this page you have to..." detail go to `docs/testing-runbook.md` via [[testing-runbook-creator]], never into this file.

The tell: if you find yourself wanting to add a project-specific detail to this skill, that wanting is the signal it belongs in the repo runbook instead. Move it there and keep this skill general.

## The general QA process

### Step 1 — Read the repo runbook for this page first

Before touching the page, check `docs/testing-runbook.md` (or the repo's testing-notes file) for an existing entry. If one exists, pull its specifics — route, selectors, test account, seed steps — and follow them. Completion: you have the page's known specifics in hand, or you have confirmed none are recorded yet.

### Step 2 — Identify and exercise the page's states

Drive the page through each state it can hold: empty (no data yet), loaded (data present), loading (in-flight), and error (request failed or bad input). Confirm each renders correctly and the transitions between them work. Completion: every applicable state has been observed, not assumed.

### Step 3 — Test forms with valid, invalid, and edge input

For each form or input, try valid input (it succeeds), invalid input (it rejects with a clear message), and edge input (empty, maximum length, special characters, boundary values). Confirm validation fires where it should and does not block what it should allow. Completion: each form has been exercised across all three input classes.

### Step 4 — Verify auth boundaries

Confirm the page enforces its access rules: an unauthenticated visitor is redirected or blocked where required, and a user without the right role cannot reach or act on what they should not. Completion: the page's auth boundary has been tested from the wrong side, not just the right one.

### Step 5 — Check responsive behavior at standard breakpoints

View the page at desktop, tablet, and mobile widths. Confirm the layout adapts without overflow, overlap, clipped content, or controls that become unreachable. Completion: the page has been seen at each breakpoint, not reasoned about.

### Step 6 — Capture screenshots as evidence and record specifics to the runbook

Take a screenshot for each finding that needs proof — a broken state, a passing layout, a failed validation. As you discover page-specific facts (the route, the selector that was hard to find, the seed step that was required), write them to the repo runbook immediately via [[testing-runbook-creator]]. Completion: findings carry screenshots, and every page specific learned this session is in the repo runbook, not in your head.

## Guardrails

- Never put a page-specific fact — selector, route, credential, seed step, cleanup quirk — into this skill; it goes to the repo's testing runbook or it is lost the next session.
- Never report a layout or state as passing without a screenshot; an unevidenced "looks fine" is not a QA result.
- Never test an auth boundary only from the authorized side; a boundary you only push from inside has not been tested.
- Never skip a state or an input class because it "should" work; QA is the act of checking the thing you assumed.

## Output contract

QA findings for the page covering its states, forms across valid/invalid/edge input, auth boundaries, and responsive behavior at desktop/tablet/mobile — each material finding carrying a screenshot — plus the page-specific facts learned this session written to the repo's testing runbook via testing-runbook-creator. The process detail stays in this skill; the page detail goes to the repo.

## Verification standard

Do not call the task done until: the repo runbook was read for this page first, every applicable state was exercised, each form was tested across valid/invalid/edge input, the auth boundary was pushed from the wrong side, the page was viewed at all three breakpoints, findings carry screenshots, and every page-specific fact learned was written to the repo runbook rather than this skill. Test by QA-ing one page in a repo the user chooses and showing both the QA findings and what was written to the runbook. Build-time note: no target page was supplied at build time, so the first real invocation is the acceptance test.
