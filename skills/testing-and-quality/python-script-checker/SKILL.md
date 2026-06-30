---
name: python-script-checker
description: >
  Use when the user asks to audit, validate, or check Python scripts
  against written documentation standards, or wants a compliance report
  on a codebase. Triggers on phrases like "check my scripts", "run a
  compliance audit", "validate against our standards", or an explicit
  /python-script-checker invocation. Writes a compliance report file
  to a specified output directory.
allowed-tools:
  - Read
  - Write
context: fork
tags: [python, testing, compliance]
audience: Software engineers and developers using Claude Code
---

# Python Script Checker

Audit a set of Python scripts against a written standard and produce a compliance report. The standard is the source of truth — this skill checks conformance to documented rules, it does not invent a style of its own.

## When to use this skill

- When the user runs `/python-script-checker` or asks to audit, validate, or check Python scripts against documented standards.
- When the user wants a compliance report on a codebase measured against a coding-standards or style document they can name.

Do not use this skill when there is no written standard to check against — without a documented rule set there is nothing to measure conformance to. Stop and ask for the standard instead of grading against your own preferences.

## Steps

### Step 1 — Locate the standard

Identify the written standard to check against: a `STANDARDS.md`, coding-guidelines doc, style guide, or the path the user names. Read it and extract a numbered list of concrete, checkable rules. If no such document exists or the user has not named one, stop and ask for it — do not proceed against an assumed standard.

### Step 2 — Enumerate the target scripts

Collect the `.py` files in scope: the directory or file list the user specified, or the repository's Python sources if they asked for a whole-codebase audit. Record the full path of each file to be checked.

### Step 3 — Check each script against each rule

For every rule from Step 1, evaluate every script in scope. Record each result as pass or fail. Every failure must carry `file:line` evidence and a one-line statement of what the rule requires and what the script does instead. Read the actual lines before recording a verdict — never infer conformance from a filename or a summary.

### Step 4 — Write the compliance report

Write a single Markdown report to the output directory the user specified (default `./compliance/`), named `python-compliance-YYYY-MM-DD.md`. The report contains: a summary table (rule, scripts checked, pass count, fail count) and a per-rule findings section where each failure lists its `file:line` and the required-versus-actual statement. Do not modify any audited script — this skill writes only the report.

### Step 5 — Report the result

State the report path and the headline counts: total scripts checked, total rules, and total failures. Point the user at the first rule with the most failures.

## Guardrails

- Never modify, reformat, or "fix" an audited script — this skill reads scripts and writes only the report.
- Never grade against an assumed standard — if no written standard is provided, stop and ask for one.
- Never record a pass or fail without reading the actual lines the rule governs.
- Never write the report outside the output directory the user specified.

## Output contract

A single Markdown compliance report at `<output-dir>/python-compliance-YYYY-MM-DD.md`, carrying a summary table (rule, scripts checked, pass count, fail count) and a per-rule findings section where every failure cites a real `file:line` and states the required-versus-actual behavior. The chat reply states the report path, the number of scripts checked, the number of rules, and the total failure count.

## Verification standard

- The report file exists at the named path inside the specified output directory.
- The rules in the report match the rules extracted from the written standard — no invented rules.
- Every failure line cites a real `file:line` that exists in an audited script.
- The summary table counts equal the sum of the per-rule findings.
- No audited script was modified during the run.
