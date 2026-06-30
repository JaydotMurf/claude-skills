---
name: open-brain-capture
description: Extract key context from the current conversation and push it to Open Brain as discrete, retrievable captures. Use when the user explicitly runs /open-brain-capture or says "push this to Open Brain", "capture this session", or "save key context to my brain".
tags: [productivity, knowledge-management, open-brain]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
allowed-tools: mcp__claude_ai_Open_Brain__capture_thought, mcp__claude_ai_Open_Brain__search_thoughts
---

# Open Brain Capture

Extract key context from the current conversation and push each piece to Open Brain as a discrete, retrievable capture.

Each capture must be a standalone statement — it must make sense when retrieved later with no conversation context available. Never write captures that reference "the conversation", "we decided", or "earlier in this session."

## Steps

### Step 1 — Scan the conversation for capturable items

Read the full conversation and extract candidates across these five categories. Pull only what is genuinely non-obvious or worth remembering — skip anything already well-documented in a committed file or that a future reader could easily re-derive.

Categories:

- Decision — a choice made that is hard to reverse, or that a future agent would re-litigate without knowing the reasoning. Format: "Decided to [X] because [Y]."
- Fact — a concrete, stable fact about the project, codebase, or system that informed the work. Format: "[Project/system] [does/uses/has] [X]."
- Insight — a non-obvious lesson or pattern discovered during the session. Format: "[X] causes/prevents/enables [Y] in this context."
- Open question — an unresolved question that should be revisited. Format: "Open question: [X]?"
- Next action — a concrete next step that was agreed on but not yet done. Format: "Next: [specific action]."

Aim for 3–8 captures per session. Quality over quantity — a capture that is too broad ("worked on skills repo") retrieves nothing useful.

### Step 2 — Check for duplicates

For each candidate, call `mcp__claude_ai_Open_Brain__search_thoughts` with the candidate's core concept as the query. If a near-identical capture already exists, drop the candidate rather than creating a duplicate.

### Step 3 — Present candidates for review

Show the user the full candidate list as a numbered list. For each candidate, show:
- The category (Decision / Fact / Insight / Open question / Next action)
- The exact text that will be pushed as the `content` field

Example format:

```
1. [Decision] Decided to keep all skills flat under skills/ rather than using category subdirectories, to match the existing repo layout.
2. [Fact] The claude-skills repo authoring standard requires four elements: frontmatter with name/description/tags/audience, a trigger description, numbered steps, and at least one guardrail.
3. [Open question] Should the open-brain-capture skill push without review, or always show candidates first?
```

Ask: "Remove any numbers you don't want captured, or reply 'all' to push everything."

Wait for the user's response before pushing anything.

### Step 4 — Push approved captures

For each approved candidate, call `mcp__claude_ai_Open_Brain__capture_thought` with the candidate text as the `content` value. Push them one at a time.

After all pushes complete, report: "Captured [N] thoughts to Open Brain." List the titles of what was saved.

## Guardrails

- Never push a capture before the user reviews and approves the candidate list.
- Never write captures that reference the conversation itself ("we discussed", "earlier you said") — every capture must be standalone.
- Never capture what is already committed to a file in the repo — Open Brain is for context that lives outside the codebase.
- Never push more than one capture per `capture_thought` call — one call per discrete thought.

## Output contract

Either a stated "nothing worth capturing" with the reason, or 3–8 discrete thoughts pushed to Open Brain — each a standalone statement in one of the five categories (Decision, Fact, Insight, Open question, Next action) — pushed only after the user approved the candidate list, with a closing report that names the count and lists the saved titles.

## Verification standard

- The numbered candidate list was shown and the user approved it before any `capture_thought` call.
- `search_thoughts` was run for each candidate, and near-duplicates were dropped.
- Every pushed capture is standalone — no "we decided", "earlier", or other conversation references.
- The closing report states the number captured and the titles saved.
