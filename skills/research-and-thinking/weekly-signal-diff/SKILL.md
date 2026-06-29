---
name: weekly-signal-diff
description: On demand, compare a defined set of inputs against the state recorded at the last run and report only meaningful changes — new signals, shifted assumptions, threads that died, patterns emerging — ordered by importance, never padded, with at most three suggested follow-ups. Use when the user asks for a weekly signal diff, "what changed", or "what's new since last time".
tags: [research-and-thinking, monitoring, diff, weekly-review]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Weekly Signal Diff

Most weekly reviews are re-summaries: they describe the whole state again whether or not anything moved. This skill does the opposite. It keeps a state file of what it saw last time and reports only the delta, so a quiet week is a short answer and a loud week surfaces what actually shifted.

## When to use this skill

Invoke it when:

- The user runs it deliberately — "weekly signal diff", "what changed since last time", "what's new".
- A regular review cadence fires and the user wants the delta, not a full status.

Do not invoke it for a first-time summary of something with no prior state to diff against (do a baseline run instead, below), and do not invoke it as a general search tool; it reports change against its own recorded history, nothing more.

## Saved defaults

These are the assumed interview answers, recorded here because the build ran without a live interview. Change them in place if they are wrong.

- Inputs watched: the notes produced by the sibling skills — `~/Documents/notes/ideas/`, `~/Documents/notes/meetings/`, and `~/Documents/notes/tasks.md`. The authoritative list lives in the state file's `watch` array; edit it there to add a folder, a notes file, a topic to search, or a project state to check.
- What counts as meaningful: for this user's GovTech / consulting / veteran-services and agent-building work — a new decision or commitment, an assumption that shifted, a thread that went silent after being active, a pattern recurring across sources, or a deadline that moved. Routine edits, typo fixes, and restatements of known facts are not meaningful.
- State file: `~/.config/agent-skills/state/weekly-signal-diff.json`. The shape is shown in `state.example.json` in this skill folder.
- Report destination: `~/Documents/notes/signal/YYYY-MM-DD-signal-diff.md`.

## Steps

### Step 1 — Load the prior state

Read the state file at `~/.config/agent-skills/state/weekly-signal-diff.json`. If it does not exist, this is a baseline run: skip the diff, go to Step 4, and record the current state as the starting point. The shipped `state.example.json` shows the exact structure to create.

### Step 2 — Check each watched input

Walk the `watch` array. For each entry, check it the way its `check` field describes — folders by files created or modified since the last run's timestamp, files by lines added or removed, topics by a fresh search, project states by their current status. Gather what is new or changed since the last run only; ignore what is unchanged.

### Step 3 — Diff against the recorded observations

Compare what you gathered against the observations stored from the last run. Identify, across all sources: new signals that were not there before, assumptions that shifted, threads that were active and have gone silent, and patterns emerging across more than one source. A real diff means comparing to the stored record, not re-reading and re-summarizing everything.

### Step 4 — Write the report, ordered by importance

Write the report to `~/Documents/notes/signal/YYYY-MM-DD-signal-diff.md`, ordering entries by how much the change matters, not by which source it came from. If nothing meaningful changed, the report is one or two honest lines saying so — that is a complete and valid answer. Never pad a quiet week with restated background to look thorough.

### Step 5 — Suggest at most three follow-ups

Close with a short section of at most three follow-ups, each tied directly to something in the diff. If the diff surfaced nothing worth following up, write none. Never manufacture follow-ups to fill the section.

### Step 6 — Update the state file

Append a new run entry to the state file's `runs` array, recording the date, timestamp, and the observations you made this run, so the next diff is measured against today. Tell the user the report path and a one-line headline of the most important change, or that nothing meaningful changed.

## Guardrails

- Never re-summarize unchanged state as if it were new; report only the delta against the recorded run.
- Never pad a quiet week; no-change is a valid, short, complete answer.
- Never suggest more than three follow-ups, and never invent a follow-up not grounded in the diff.
- Never finish without appending this run's observations to the state file; an un-updated state file makes the next diff a re-summary.

## Output contract

A Markdown report at `~/Documents/notes/signal/YYYY-MM-DD-signal-diff.md` listing meaningful changes ordered by importance (or a one-to-two-line no-change statement), closing with at most three diff-grounded follow-ups. The state file at `~/.config/agent-skills/state/weekly-signal-diff.json` gains one new run entry. The chat reply states the report path and the headline change.

## Verification standard

Do not call the task done until: the report contains only changes relative to the last recorded run (or an honest no-change line), entries are ordered by importance rather than by source, follow-ups number three or fewer and each ties to the diff, and the state file has a new run entry timestamped today. Build-time note: a baseline run requires the user's live notes folders, which are outside this repo, so the baseline executes at first real invocation; `state.example.json` is the validated shape that baseline writes (verified well-formed with `jq` at build time).
