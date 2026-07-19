---
name: intention-clarifier
description: Turn a vague intention, nagging thought, or half-formed idea into a stated goal with a concrete first step. Use when the user says "I'm not sure what I want", "something's been on my mind", "help me figure out", "I have this idea but...", or is stuck, overwhelmed, or unable to articulate what they actually need — before any planning or delegation.
tags: [research-and-thinking, clarity, goals, decision]
audience: engineers, operators, and solo builders
source: open-skills
---

# Intention Clarifier

A vague intention is a signal with the goal stripped out. Acting on it directly produces motion without direction; planning it produces a tidy plan for the wrong thing. This skill surfaces what the person actually wants before any of that, and ends on the one concrete step that moves it.

## When to use this skill

Invoke it when:

- The user expresses a vague desire or a nagging thought — "something's been on my mind", "I have this idea but I can't pin it down".
- The user says "help me figure out", "I'm not sure what I want", "what should I do about...", or seems stuck or overwhelmed.
- A real goal is buried under a surface request, and acting on the surface request would miss it.
- Another skill needs a fuzzy intention resolved into a clear goal before it can plan, break down, or delegate the work.

Do not invoke it when the goal is already clear and only the plan is missing — hand that to a planning or breakdown flow. Do not invoke it to stress-test an existing plan; `grilling` and `grill-me` own that. Do not invoke it for a multi-topic brain dump; `brain-dump-processor` separates those.

## Steps

### Step 1 — Reflect back what you heard, before asking anything

Restate the intention in three parts, so a misread surfaces immediately:

- The core desire seems to be: your one-sentence interpretation.
- The underlying tension or problem: the thing creating the itch.
- Possible goals hiding in this: two or three distinct interpretations, not one.

Then ask a single question: is any of this wrong or missing something important? Completion: the user has confirmed or corrected the reflection.

### Step 2 — Ask only the questions that earn their place

From the bank below, select the few that actually fit this intention — never all of them, never a batch. Ask one at a time and wait for the answer before choosing the next, because each answer changes which question matters next. If a question can be answered from context already given, do not ask it.

Clarifying the WHAT:

- If this were completely resolved, what would be different — what would you see, feel, or have?
- Is this starting something new, changing something existing, or stopping something?
- Are there several things tangled together here that should be separated?

Clarifying the WHY:

- Why does this matter now — what changed, or what is the trigger?
- What happens if you do nothing — what is the cost of inaction?
- Is this something you want, or something you think you should want?

Clarifying the HOW:

- What have you already tried, and what happened?
- What would make this easy — what help, resource, or condition would remove the friction?
- What is the scariest or most uncomfortable part of this?

Clarifying the CONSTRAINTS:

- What does "good enough" look like — the minimum viable version?
- What can you not change about this situation?
- By when does something actually need to happen?

Completion: you can state the real goal in one sentence and the person agrees it is right.

### Step 3 — State the clarified intention in the fixed format

Produce exactly these fields:

- The real goal: one clear sentence for what the person actually wants.
- Why this, why now: the actual driver that makes it worth doing.
- What success looks like: a concrete description of the end state.
- What is actually in the way: the real blocker — practical, emotional, or clarity itself.
- The first concrete step: one specific action takeable in the next 24 hours that moves this forward.
- What this unlocks: why that first step matters — what becomes possible after it.

### Step 4 — Route to the next move

Name the honest next move and, where a skill owns it, hand it off:

- Ready to act — the path is clear enough; do the first concrete step now.
- Needs breakdown — the goal is clear but the path has open decisions; run `grilling` to resolve the design tree, or decompose it into next actions directly.
- Needs delegation — this should be handed to another agent session; run `goal-prompt-generator` to package it.
- Learning-shaped — the real goal is to understand or learn something; run `teach`.
- Needs more thinking — schedule dedicated time; this will not resolve in one pass.
- Not actually important — drop it or defer it, and say so plainly.

### Step 5 — If it is still fuzzy, escalate to meta-questions

If the intention will not resolve after Step 2, ask:

- What would need to be true for this to feel clear?
- Is this one thing, or several things wearing a trench coat?
- What are you afraid of discovering if you look closer?

A fuzzy intention sometimes protects the person from something. That is itself useful information — name it rather than forcing a false resolution.

## Guardrails

- Never propose solutions before the real goal is stated and confirmed.
- Never accept a surface-level answer when the question was about the underlying motivation; ask again.
- Never dump all twelve questions at once; select the relevant few and ask one at a time.
- Never skip the Step 1 reflection-back; it is the cheapest place to catch a misread.
- Never force a clarified goal when Step 5 shows the intention is protecting the person from something; surface that instead.

## Output contract

An intention-statement produced in the conversation with all six Step 3 fields — real goal, why now, what success looks like, what is in the way, the first concrete 24-hour step, and what it unlocks — followed by one named next move from Step 4. The skill writes no files itself; a caller persists the result if needed.

## Verification standard

Do not call it done until: the Step 1 reflection was confirmed or corrected by the user; the real goal is stated in one sentence the user agrees with; the first step is concrete and takeable within 24 hours, not a category of action; and exactly one Step 4 next move is named. If the intention stayed fuzzy through Step 5, the honest output is the named reason it will not resolve — that also counts as done.
