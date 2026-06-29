---
name: browser-qa
description: Drive a real Chrome browser through the Chrome DevTools MCP server to verify web changes — screenshots at desktop/tablet/mobile for layout, a performance trace with Core Web Vitals against thresholds for perf-relevant changes, console-error and failed-request checks for new features. Every finding ships with its screenshot, metric, or log excerpt; nothing passes on an unevidenced "looks fine". Use when asked to verify a web change, check performance, audit a page, or test responsive behavior.
tags: [testing-and-quality, browser, qa, performance, web-vitals, mcp, chrome-devtools, evidence]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Browser QA

Reasoning about a page from its source is guessing. This skill verifies web changes against a real browser through the Chrome DevTools MCP server — navigating, screenshotting, reading the console and network, and recording performance traces — and holds every finding to evidence. The rule that makes it trustworthy is simple: no screenshot, metric, or log excerpt, no claim.

## Setup — Chrome DevTools MCP server

This skill depends on the `chrome-devtools-mcp` server being connected to the harness. Confirm it before running; set it up once if it is absent.

Requirements: Node.js LTS and a current-stable (or newer) Chrome installed.

Install for Claude Code (user scope, so it is available across projects):

```
claude mcp add chrome-devtools --scope user npx chrome-devtools-mcp@latest
```

Then restart the harness and verify the connection (`/mcp` in Claude Code should list `chrome-devtools` as connected, and its tools — `navigate_page`, `take_screenshot`, `list_console_messages`, `list_network_requests`, `performance_start_trace`, `emulate`, `resize_page` — should be available). If you are on a different harness, run its equivalent MCP-add command for the `chrome-devtools-mcp@latest` npm package and verify the tools are present. Do not write or run a QA report until the connection is verified; an unconnected server fails silently into guesswork.

Recorded assumption (build time): install is pinned to the `chrome-devtools-mcp@latest` npm package at user scope, verified against the ChromeDevTools/chrome-devtools-mcp tool list as of 2026-06-29. The MCP server was not live-connected at build time, so the first real invocation against a running page is the acceptance test.

## When to use this skill

Invoke it when the user asks to:

- Verify a web change renders and behaves correctly.
- Check a page's performance or Core Web Vitals.
- Audit a page, or test its responsive behavior across breakpoints.

Do not invoke it for backend or API verification with no rendered page, for unit or integration tests that need no browser, or for static visual design critique with no running target. If there is no live page to drive, this skill has nothing to measure.

## Check recipes by change type

Match the recipe to what changed; run more than one when a change spans types.

- Layout change — screenshot the page at desktop, tablet, and mobile breakpoints using `resize_page` (or `emulate` for a device profile) and `take_screenshot`, and inspect each for overflow, overlap, clipping, and unreachable controls.
- Performance-relevant change — record a trace with `performance_start_trace` / `performance_stop_trace`, read LCP, INP, and CLS, and compare each against its threshold (defaults: LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1 — the Core Web Vitals "good" bounds; use the user's stated thresholds when they give them).
- New feature — script a walkthrough of the feature with the input tools (`navigate_page`, `click`, `fill`), and during it collect `list_console_messages` for errors and `list_network_requests` for failed (4xx/5xx) or hanging requests.

Recorded assumption (build time): the Core Web Vitals "good" thresholds above are the defaults when the user states none.

## Steps

### Step 1 — Confirm the server and read the runbook

Verify the `chrome-devtools` MCP connection is live, then check the repo's `docs/testing-runbook.md` (per [[testing-runbook-creator]]) for an existing recipe for this page — route, test account, seed steps — and follow it. Completion: the server is connected and you have the page's known specifics or have confirmed none exist.

### Step 2 — Classify the change and pick the recipes

Determine what changed (layout, performance, new feature, or a combination) and select the matching check recipes. Completion: you know which recipes you will run and why.

### Step 3 — Run the checks and collect evidence

Execute each selected recipe against the live page, capturing the artifact each one produces — screenshots per breakpoint, the trace metrics, the console and network excerpts. Tie every observation to its artifact as you go. Completion: each check has produced its evidence.

### Step 4 — Write the report and record page specifics to the runbook

Write the short report (format below). For each finding about how to test this page — a selector, a route, a seed step, a flaky wait — write it to the repo's testing runbook via [[testing-runbook-creator]]. Completion: the report is evidenced and the page-specific testing knowledge is in the runbook.

## Report format

Keep it short and structured:

- Checked — what was checked and at what breakpoints / against what thresholds.
- Passed — each pass with its evidence (screenshot path, metric value vs. threshold, clean console/network).
- Failed — each failure with its evidence and exact reproduction steps (the route, the action, the breakpoint or input that triggered it).

## Guardrails

- Never report a result without its evidence; every pass and every failure ships with a screenshot, a metric, or a log excerpt, and "looks fine" with nothing attached is not a result.
- Never run a check against the page's source or your memory of it instead of the live browser; if the MCP server is not connected, stop and connect it rather than guessing.
- Never report a failure without exact reproduction steps; a failure the next person cannot reproduce is noise.
- Never put a page-specific testing fact in this skill; it goes to the repo's testing runbook via testing-runbook-creator.

## Output contract

A short structured report — Checked, Passed, Failed — where every line carries its evidence (screenshot, Core Web Vitals metric against its threshold, or console/network excerpt) and every failure carries exact reproduction steps, produced by driving the live page through the Chrome DevTools MCP server. Page-specific testing facts learned during the audit are written to the repo's testing runbook, not this skill.

## Verification standard

Do not call the task done until: the `chrome-devtools` MCP connection was confirmed live, the recipes matching the change type were run against the real page, every reported result carries its screenshot/metric/log evidence, Core Web Vitals were compared against stated or default thresholds where performance was in scope, every failure has reproduction steps, and page specifics were written to the repo runbook. Test by auditing one live page the user supplies and showing the report. Build-time note: the MCP server was not live-connected at build time, so the first real audit against a running page is the acceptance test.
