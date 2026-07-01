---
name: release-briefing
description: Turn gathered release data about a new model, tool, or platform change into a publish-ready briefing package with a fixed structure, dated and sourced facts, a standardized title and subtitle, and thumbnail image prompts. Use when the user says "brief me up on <release>" or hands over release research to package. Packages only — if research is missing or stale, it stops and runs current-info-search first.
tags: [writing, content, briefing, release-notes, publishing]
audience: engineers, operators, and solo builders
source: open-skills
---

# Release Briefing

Takes research about a release (a new model, tool, or platform change) and packages it into a publish-ready briefing. The structure is fixed so every briefing reads the same way, and every factual claim carries a date and a source. This skill packages existing research; it does not gather it. When the research is missing or stale, it hands off to current-info-search before writing a word.

## When to use this skill

Invoke it when:

- The user says "brief me up on <release>" or names a release to package.
- The user hands over release research, notes, or links to turn into a briefing.

Do not invoke it for original reporting where no research exists yet (gather first), for general writing with no release subject, or for content that is not aimed at the user's publication audience.

## Saved defaults

- Briefing profile path: `~/.config/agent-skills/briefing-profile.md`, holding the publishing venue, audience sophistication, and title and format conventions. Assumption recorded on build: this location matches the other agent-skills profiles. Override with `BRIEFING_PROFILE_PATH`.
- Default package structure assumed on build until the interview overrides it: title, subtitle, "What changed", "Why it matters", "What to do about it", and 2–3 thumbnail image prompts.

## Steps

### Step 1 — Load or build the profile

Read `~/.config/agent-skills/briefing-profile.md`. If it exists, load it. If it does not, interview the user for: where they publish (newsletter, blog, internal doc), their audience's sophistication level, and their title and format conventions if they have any. Write the answers to the profile file. Completion: you hold the venue, audience level, and title and format conventions.

### Step 2 — Check the research is present and fresh

Confirm you have research that names the release and is current. If research is missing, thin, or possibly stale (dates older than the release, no primary sources, claims you cannot date), stop and run the current-info-search skill to gather dated, sourced facts before continuing. Completion: you hold release facts that each carry a date and a primary source.

### Step 3 — Sort facts from claims

Separate confirmed facts (a date and a primary source exist) from unverified claims. Every confirmed fact keeps its date and source through to the final package. Every unverified claim is labeled as unverified in the package, not dropped silently and not promoted to fact. Completion: each item is tagged confirmed-with-source or unverified.

### Step 4 — Assemble the package

Build the package in this fixed structure:

1. Title — standardized to the user's conventions from the profile.
2. Subtitle — one line stating the stakes for this audience.
3. What changed — the facts, each with its date and primary source; unverified items labeled as such.
4. Why it matters — the consequence for this specific audience at their sophistication level.
5. What to do about it — concrete next actions for the reader.
6. Thumbnail prompts — 2–3 image prompts matched to the release subject's brand colors, ready to hand to the branded-image-prompting or image-gateway skill.

Completion: all six parts are present.

### Step 5 — Write the post through the voice skill

If a my-voice profile exists, render the prose parts (subtitle, "Why it matters", "What to do about it") through the my-voice skill so the briefing reads in the user's voice. If no voice profile exists, write plainly and note that voice was not applied. Completion: the prose is either voiced or explicitly marked unvoiced.

### Step 6 — Test

On first build, run the skill on the most recent significant release in the user's field and show the full package for review. Completion: a complete package exists for one real recent release.

## Guardrails

- Never present a factual claim without its date and primary source; label anything unverified as unverified rather than dropping or promoting it.
- Never gather or invent release facts inside this skill; if research is missing or stale, stop and run current-info-search first.
- Never publish past a stale-research check; an out-of-date briefing is worse than a late one.
- Never let the thumbnail prompts drift from the release subject's actual brand colors.

## Output contract

A single briefing package in fixed order: standardized title, subtitle, "What changed" (dated and sourced facts, unverified items labeled), "Why it matters", "What to do about it", and 2–3 thumbnail image prompts matched to the subject's brand colors. Prose is rendered through my-voice when a profile exists, or marked unvoiced when it does not.

## Verification standard

Do not call the task done until: every fact in "What changed" carries a date and a primary source, every unverified claim is labeled, all six structural parts are present, and the research freshness check in Step 2 passed (or current-info-search was run). Build-time test: produce a complete package for the most recent significant release in the user's field.
