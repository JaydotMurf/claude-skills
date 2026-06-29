---
name: audience-content-system
description: Generate content for a specific publication calibrated to its audience's exact level, in the user's established formats, with a batch-planning mode for whole cycles. Use when planning or drafting anything for that publication. Enforces an audience contract (knowledge floor and ceiling, banned jargon) and a calibration check before any draft ships.
tags: [writing, content, audience, publishing, calibration]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Audience Content System

Generates content for one publication, pitched precisely at its audience. The audience is pinned down once as a contract (what readers already know, what they definitely do not, which jargon is banned and what replaces it), and every piece is calibrated against it before delivery. The skill carries a template per content format and a batch-planning mode that maps a theme to a full cycle of pieces before any drafting starts.

## When to use this skill

Invoke it when:

- The user is planning content for this publication (a week, a cycle, a theme).
- The user is drafting any individual piece for this publication.

Do not invoke it for one-off writing with no fixed audience, for a different publication with a different audience contract, or for content where the user wants to deliberately write above or below the established level.

## Saved defaults

- Audience profile path: `~/.config/agent-skills/audience-profile.md`, holding the publication, the audience contract, the format templates, the cadence, and the example pieces. Assumption recorded on build: this matches the other agent-skills profiles. Override with `AUDIENCE_PROFILE_PATH`.
- One publication per profile. For a second publication, keep a second profile file and name it.

## Steps

### Step 1 — Load or build the profile

Read `~/.config/agent-skills/audience-profile.md`. If it exists, load it. If it does not, interview the user for: the publication and its audience (who they are, what they already know, what they definitely do not), the content formats with length and structure for each (for example short tip, concept explainer, tutorial), the publishing cadence, and 2–3 examples of pieces that landed well. Write the answers to the profile file. Completion: you hold the audience contract, a template per format, the cadence, and the example pieces.

### Step 2 — Set the audience contract

State the contract explicitly before writing anything: the knowledge floor (what every reader already knows, so you never over-explain it), the knowledge ceiling (what they do not know, so you always explain it), and the banned jargon list with a plain-language substitution for each banned term. Completion: floor, ceiling, and banned-jargon-with-substitutions are written down.

### Step 3 — Choose the mode

If the user gave a theme or asked to plan, go to batch-planning (Step 4). If the user asked for a single piece in a known format, go to drafting (Step 5). Completion: mode chosen.

### Step 4 — Batch-planning mode

Given a theme, propose a full week or cycle of pieces across the formats before drafting any of them. For each planned piece give the format, the working title, the single idea it carries, and where it sits in the cadence. Show the plan and get approval before drafting. Completion: an approved cycle plan exists.

### Step 5 — Draft against a template

Draft the requested piece (or the next piece from the approved plan) using that format's template from the profile for length and structure. Keep every claim inside the audience contract: nothing below the floor over-explained, nothing above the ceiling left unexplained, no banned jargon. Completion: a draft that fits its format template and respects the contract.

### Step 6 — Calibration check before delivery

Before showing any draft, run the calibration check: "Would my least technical reader follow every step?" If any step assumes knowledge above the floor or uses banned jargon, fix it before delivering. Completion: the draft passes the least-technical-reader check.

### Step 7 — Test

On first build, plan one content batch on a theme the user gives you, then draft the shortest piece from that plan and show both for judgment. Completion: a batch plan plus the shortest drafted piece exist.

## Guardrails

- Never ship a draft that fails the calibration check; if the least technical reader could not follow a step, the step is rewritten or cut.
- Never use a term on the banned-jargon list; substitute the plain-language replacement from the contract every time.
- Never draft pieces in batch-planning mode before the user has approved the cycle plan.
- Never write above the knowledge ceiling or below the knowledge floor for this audience.

## Output contract

In planning mode: a full week or cycle of pieces, each with format, working title, single idea, and cadence slot, presented for approval before any drafting. In drafting mode: a single piece that fits its format template, respects the audience contract, and has passed the calibration check. The audience contract (floor, ceiling, banned jargon with substitutions) is stated alongside the output.

## Verification standard

Do not call the task done until: the audience contract is stated, the draft fits its format template, no banned jargon appears, and the calibration check passed. Build-time test: plan one content batch on a user-supplied theme and draft the shortest piece from the plan.
