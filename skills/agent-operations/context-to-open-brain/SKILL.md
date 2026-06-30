---
name: context-to-open-brain
description: >
  Extracts the durable, reusable knowledge from the current conversation and pushes it to
  Open Brain as discrete, retrievable captures. Use when the user says "push this to my
  brain", "save this context", "capture what we built", "log this to Open Brain", "save our
  progress", or "I keep asking for the same thing — automate it". Also trigger proactively at
  the end of any session that established significant decisions, tools, scripts, workflows, or
  project structure — do not wait to be asked when a session produced durable knowledge. Do not
  trigger for an exploratory chat that reached no decision or built nothing reusable.
tags: [productivity, knowledge-management, open-brain]
audience: Software engineers and developers using Claude Code
allowed-tools: mcp__claude_ai_Open_Brain__capture_thought, mcp__claude_ai_Open_Brain__search_thoughts
---

# Context to Open Brain

Extract structured, retrievable captures from the current conversation and push each one to Open Brain through `capture_thought`. Every capture must stand alone — it should make full sense when retrieved weeks later with no surrounding context.

## When to use this skill

Use it when the user asks to save context in any of the forms in the description, and use it proactively at the end of a session that produced durable, reusable knowledge: a script or tool, a project structure, a decision with a rationale, a recurring workflow, or an integration detail.

Do not use it for exploratory discussion that reached no decision, for content already in Open Brain, or for a session that built nothing worth retrieving later. Restraint is part of the quality bar — not every exchange becomes a capture.

## What to capture

Scan the conversation for these categories and capture each one that is present:

- Project or repo structure — names, locations, folder layout, naming conventions.
- Scripts or tools built — what they do, where they live, how to run them, dependencies.
- Decisions made — why one option was chosen over another, and what was ruled out and why.
- Workflow patterns — the established sequence of steps for a recurring task.
- Credentials and env vars — the key name and where it is stored, never the value.
- APIs and integrations — endpoints, models, auth method, rate limits.
- Conventions — naming schemes, file structures, commit message formats.

Skip these:

- Exploratory discussion that did not result in a decision.
- Content already in Open Brain — search first when unsure.
- Raw terminal output, unless it reveals a configuration detail worth keeping.
- Troubleshooting steps that did not lead to a fix.

## Capture format

Each capture must be:

- Self-contained — it reads clearly with zero surrounding context.
- Specific — it includes file paths, tool names, model strings, and env var names.
- Third-person — name the actor explicitly (the user by name), not "we built X".
- Atomic — one topic per capture; split a compound capture into separate ones.

A good capture:

> Dana's pdf_to_markdown.py lives at ~/toolkit/file-tools/pdf_to_markdown.py. It batch-converts PDFs via the markdown.new POST /convert API. Run with `python file-tools/pdf_to_markdown.py --input <dir> --output <dir>`. Requires the requests library; venv at ~/toolkit/.venv.

A bad capture:

> We talked about the PDF script and also the toolkit structure and some GitHub stuff.

## Steps

### Step 1 — Confirm Open Brain is available

If the Open Brain MCP is not connected, stop and tell the user to enable it before proceeding. Do not attempt to capture without it.

### Step 2 — Search first

For each main topic, call `search_thoughts` to avoid duplicating an existing capture. If a capture already covers the topic, add a new one only when this session added meaningfully new detail.

### Step 3 — Extract

Identify every capture-worthy item from the conversation using the categories above.

### Step 4 — Draft

Write each capture out before pushing, two to five sentences each, in the format above. If there are more than five, show the user the list and ask for a quick sanity check before pushing.

### Step 5 — Push

Call `capture_thought` once per item. Never batch multiple topics into one capture.

### Step 6 — Confirm

After all captures are pushed, tell the user how many were saved and what topics they covered. Keep it brief.

## Guardrails

- Never capture an API key value, password, or token — capture only the env var name and where it is stored.
- Never write a capture that references the conversation itself ("we discussed", "earlier") — every capture must be standalone.
- Never push more than one topic per `capture_thought` call — one call per discrete thought.
- Never push a capture for a topic already in Open Brain unless this session added new detail.
- Never capture content that is already committed to a file in the repo — Open Brain holds context that lives outside the codebase.

## Output contract

Either a stated "nothing worth capturing" with the reason, or a set of discrete thoughts pushed to Open Brain — each one standalone, specific, third-person, and atomic, drawn from the capture categories — pushed after a sanity check when there are more than five, with a closing report that names the count and the topics covered.

## Verification standard

- The Open Brain MCP was confirmed available before any capture; if it was not, the user was told and nothing was pushed.
- `search_thoughts` was run per topic, and duplicates were dropped unless this session added new detail.
- Every pushed capture is standalone and carries its concrete specifics (paths, tool names, model strings, env var names), with no secret values.
- Captures are atomic — no compound capture mixing topics — and written in third person.
- The closing report states the number captured and the topics covered.
