---
name: my-voice
description: Write, rewrite, or review text in the user's authentic voice using a stored voice profile that models their distinct registers, sentence patterns, and anti-patterns. Use whenever the user asks to write, rewrite, or review something in their voice. Build the profile from real samples on first use; other writing skills call this to apply the voice.
tags: [writing, voice, style, content, personal-profile]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# My Voice

A model of how the user actually writes, not a single tone preset. Voice is captured once from real samples, stored as a profile, and applied every time the user asks for writing in their voice. The profile holds several registers (directive, relational, analytical, business) and the rules for choosing between them, so the agent shifts register the way the person does instead of flattening everything to one tone.

## When to use this skill

Invoke it when:

- The user asks to write something in their voice (an email, a post, a doc, a message).
- The user asks to rewrite or edit existing text so it sounds like them.
- The user asks you to review a draft for whether it sounds like them.
- Another writing skill needs to render its output in the user's voice and calls this skill to apply the profile.

Do not invoke it for writing where a house style or someone else's voice is required, for code or config, or for content where the user has asked for a neutral or institutional tone on purpose.

## Saved defaults

- Voice profile path: `~/.config/agent-skills/voice-profile.md`. Assumption recorded on build: this location keeps the profile beside the other agent-skills config and out of any repo. Override with `VOICE_PROFILE_PATH`.
- The profile is built once from samples and reused. Rebuild only when the user says their writing has changed or asks to refresh it.

## Steps

### Step 1 — Load or build the profile

Read `~/.config/agent-skills/voice-profile.md`. If it exists, load it and skip to the step that matches the request (write, rewrite, or review). If it does not exist, tell the user you need to build it and continue to Step 2. Completion: you either hold a profile or know you must build one.

### Step 2 — Collect samples

Ask the user for 5–10 real writing samples across different contexts: emails, posts, documentation, casual messages. Ask for spread across contexts, not five versions of the same thing, because the registers only show up across contexts. Completion: you have at least five samples spanning at least three contexts.

### Step 3 — Analyze and propose

Analyze the samples and propose, in writing, four things:

1. Distinct registers (for example directive, relational, analytical, business), each with the one or two features that distinguish it from the others.
2. Sentence-level patterns the user actually uses: typical length, rhythm, punctuation habits, how they open and close, contractions, how they handle lists.
3. Anti-patterns: specific words, openers, and constructions they never use, plus common AI-prose tells to avoid on their behalf (leverage, utilize, seamlessly, robust, cutting-edge, "in today's world", "it's worth noting", em-dash pile-ups, tidy rule-of-three summaries).
4. Register-selection rules: which register fits which audience and stakes level.

Completion: a written analysis covering all four parts.

### Step 4 — Review before finalizing

Show the analysis to the user and ask for corrections. Do not write the profile until they confirm the registers and rules are right. Completion: the user has approved or corrected the analysis.

### Step 5 — Write the profile

Write the approved analysis to `~/.config/agent-skills/voice-profile.md`. Include the register model with one short sample of each register, the sentence-level patterns, the anti-pattern list, and the register-selection rules. Completion: the file exists and contains all four parts plus a sample per register.

### Step 6 — Apply the voice

For a write or rewrite request: pick the register that fits the audience and stakes using the profile's rules, draft in that register, and check the draft against the anti-pattern list before showing it. For a review request: judge the draft against the profile and name which register it should be in, where it drifts, and which anti-patterns it triggers. Completion: the output matches a named register and clears the anti-pattern list.

### Step 7 — Test and grade

On first build, draft one short email and one short post on topics the user gives you, then ask the user to grade them. Record any correction back into the profile. Completion: the user has graded both test pieces.

## Guardrails

- Never bend a fact to make text sound more like the user; for technical content, accuracy beats voice, and a true sentence in a slightly off register is always preferred over a false one that sounds right.
- Never invent a voice or guess at registers without real samples; if the user will not provide samples, say you cannot build the profile rather than fabricating one.
- Never apply a register the profile's rules do not select for that audience and stakes level.
- Never let any anti-pattern from the profile reach a draft you present.

## Output contract

On first use: a voice profile written to `~/.config/agent-skills/voice-profile.md` containing the register model with one sample per register, the sentence-level patterns, the anti-pattern list, and the register-selection rules. On every later use: a draft, rewrite, or review that names the register it uses and has been checked against the anti-pattern list.

## Verification standard

Do not call the task done until: the profile file exists with all four parts and a sample per register; the user has approved the analysis; the presented draft clears the anti-pattern list; and any technical claim in the draft is accurate regardless of voice. Build-time test: draft one short email and one short post on user-supplied topics and confirm the user grades them.
