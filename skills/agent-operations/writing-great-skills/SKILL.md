---
name: writing-great-skills
description: Reference for writing and editing skills well — the vocabulary and principles that make a skill predictable. Use when the user explicitly runs /writing-great-skills or asks for guidance on authoring or improving a skill.
tags: [productivity, skills, authoring]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
source: mattpocock
---

# Writing Great Skills

A skill exists to wrangle determinism out of a stochastic system. Predictability — the agent taking the same process every run, not producing the same output — is the root virtue. Every principle below serves it.

Terms used below are defined in [references/GLOSSARY.md](references/GLOSSARY.md).

## Steps

### Step 1 — Load and apply the reference

Use the vocabulary and principles below when writing or reviewing any skill.

## Invocation

Two choices, trading different costs:

- A model-invoked skill keeps a description, so the agent can fire it autonomously and other skills can reach it. It contributes to context load — the description sits in the window every turn. Mechanics: omit `disable-model-invocation`, and write a model-facing description with rich trigger phrasing ("Use when the user wants…, mentions…").
- A user-invoked skill strips the description from the agent's reach: only the human typing its name can invoke it. Zero context load, but it spends cognitive load: the user is the index that must remember it exists. Mechanics: set `disable-model-invocation: true`; the `description` becomes human-facing — a one-line summary, trigger lists stripped.

Pick model-invocation only when the agent must reach the skill on its own, or another skill must. If it only ever fires by hand, make it user-invoked.

When user-invoked skills multiply past what you can remember, the cure is a router skill: one user-invoked skill that names the others and when to reach for each.

## Writing the description

A model-invoked description does two jobs — state what the skill is, and list the branches that should trigger it. Every word increases context load, so it earns even harder pruning than the body:

- Front-load the skill's leading word.
- One trigger per branch. Synonyms that rename a single branch are duplication — collapse them.
- Cut identity that's already in the body. Keep the description to triggers, plus any "when another skill needs…" reach clause.

## Information hierarchy

A skill is built from two content types — steps and reference — that mix freely. The core decision is which to use and where each sits on the information hierarchy, ranked by how immediately the agent needs the material:

1. In-skill step — an ordered action in `SKILL.md`: what the agent does, in order. Each step ends on a completion criterion, the condition that tells the agent the work is done. Make it checkable (can the agent tell done from not-done?) and exhaustive where it matters.
2. In-skill reference — a definition, rule, or fact in `SKILL.md`, consulted on demand. A legitimately flat peer-set (every rule of a review on one rung) is a fine arrangement, not a smell.
3. External reference — reference pushed out of `SKILL.md` into a sibling file, reached by a context pointer, loaded only when the pointer fires.

Push too little down and the top bloats; push too much and you hide material the agent actually needs.

Progressive disclosure is the move down the ladder — out of `SKILL.md` into a linked file — so the top stays legible. Mechanics: a linked `.md` file in the skill folder, named for what it holds.

## When to split

Split only when the cut earns its cost. Two cuts:

- By invocation — split off a model-invoked skill when you have a distinct leading word that should trigger it on its own, or another skill must reach it.
- By sequence — split a run of steps when the steps still ahead tempt the agent to rush the current one (premature completion).

## Pruning

Keep each meaning in a single source of truth: one authoritative place.

Check every line for relevance: does it still bear on what the skill does?

Hunt no-ops sentence by sentence: run the no-op test on each sentence in isolation. When one fails, delete the whole sentence rather than trim words.

## Leading words

A leading word is a compact concept already in the model's pretraining that the agent thinks with while running the skill (e.g. lesson, fog of war, tracer bullets). Repeated throughout the text, it accumulates a distributed definition and anchors a whole region of behaviour in the fewest tokens.

Hunt for opportunities to refactor skills to use leading words. A triad spelled out at three sites (duplication), a description spending a sentence to gesture at one idea — each is a passage begging to collapse into a single token.

## Failure modes

- Premature completion — ending a step before it's genuinely done, attention slipping to being done. Defence: sharpen the completion criterion first; only if it's irreducibly fuzzy and you observe the rush, split the sequence.
- Duplication — the same meaning in more than one place. Costs maintenance and tokens.
- Sediment — stale layers that settle because adding feels safe and removing feels risky.
- Sprawl — a skill simply too long, even when every line is live. Cure: disclose reference behind pointers, and split by branch or sequence.
- No-op — a line the model already obeys by default. The test: does it change behaviour versus the default?

## Guardrails

- Never write the same meaning in more than one place — keep a single source of truth for each concept.
- Never add a step whose completion criterion is vague — make it checkable.
- Never use bold formatting inside prose.

## Output contract

A skill authored or edited toward predictability. Applying the reference produces a
deliberate invocation choice (model-invoked only when the agent or another skill must
reach it, otherwise user-invoked), a pruned trigger-only description, content placed
correctly on the information hierarchy with reference disclosed behind pointers, splits
made only by invocation or sequence when they earn their cost, and leading words used
where they collapse repetition. The deliverable is guidance applied to a skill, not a
separate artifact.

## Verification

The skill under authoring or review is done when:

- Each meaning lives in a single source of truth, and no no-op lines survive the
  no-op test.
- Every step ends on a checkable completion criterion.
- The invocation mode matches whether the agent must reach the skill on its own, and no
  bold formatting appears in prose.
