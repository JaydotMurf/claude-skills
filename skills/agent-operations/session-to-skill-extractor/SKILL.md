---
name: session-to-skill-extractor
description: At the end of a substantial work session, evaluate whether anything done is worth preserving as a new skill or an update to an existing one, against a high bar — the pattern must be recurring, non-obvious, and codifiable — and if so, draft it in the library's standard format for review. Checks the existing skill library first and proposes an update when one already covers most of the pattern. Trigger when the user says "wrap up" or "anything worth keeping?", or at the natural end of a session that solved something non-trivial.
tags: [agent-operations, knowledge-capture, skill-authoring, retrospective]
audience: engineers, operators, and solo builders
source: open-skills
---

# Session to Skill Extractor

Most work sessions produce nothing worth keeping as a skill, and that is the normal outcome. This skill runs the honest evaluation at the end of a substantial session: was there a pattern here worth codifying, and if so, is it a new skill or an update to one that exists. The default answer is "nothing worth extracting," and reaching that answer by actually checking is a success, not a failure.

## When to use this skill

Invoke it when:

- The user says "wrap up," "anything worth keeping?", or asks whether the session produced anything reusable.
- The session reaches a natural end after solving something non-trivially.

Do not invoke it mid-task, after a routine session where nothing non-trivial was solved, or as a way to manufacture skills to look productive. The bar is high on purpose; if the session was ordinary, the correct output is a one-line "nothing worth extracting."

## The extraction bar

A pattern earns extraction only if it clears all three tests. State the verdict against each one explicitly.

- Recurring: the user will plausibly hit this again. A one-off fix for a unique situation does not qualify.
- Non-obvious: a fresh session would not just derive it from the task. If the next agent would naturally do the same thing without the skill, there is nothing to capture.
- Codifiable: it can be written as a repeatable procedure with trigger conditions, not just a story about what happened.

A pattern that fails any one of the three is not extracted. Most sessions fail at least one.

## Steps

### Step 1 — Decide whether the session even qualifies

Ask whether the session solved anything non-trivial. If it was routine, stop here and report "nothing worth extracting." Completion: a decision on whether to evaluate further, with the routine case short-circuited.

### Step 2 — Name the candidate pattern in one sentence

If something non-trivial happened, state the candidate pattern as one sentence: the reusable move, independent of this session's specifics. If you cannot state it in a sentence, it is probably not codifiable yet. Completion: a one-sentence candidate pattern, or a stop.

### Step 3 — Test it against the bar, explicitly

Run the candidate against recurring, non-obvious, and codifiable, and write the verdict for each. If it fails any one, stop and report which test it failed and why — that reasoning is the deliverable, not a new skill. Completion: a per-test verdict; either a pass on all three or a documented fail.

### Step 4 — Check the existing skill library first

Before drafting anything new, search the existing skill library for overlap. If an existing skill already covers about 80% of the pattern, propose an update to that skill rather than a new one — a near-duplicate skill is worse than an extended existing one. Completion: a decision of new-skill versus update-existing, naming the existing skill if there is overlap.

### Step 5 — Sanitize: generalize the pattern, strip the specifics

Separate the reusable pattern from this session's project, client, and repo specifics. The skill captures the generalized procedure; the project-specific details stay in a repo-local runbook, not in the skill. Completion: a generalized pattern with project/client specifics removed.

### Step 6 — Draft in the standard format, for review only

Draft the new skill or the proposed update in the library's standard format — the six-element standard with frontmatter and trigger conditions — and land it somewhere for the user's review (a draft file or the message), never silently into the live library. Completion: a draft in standard format, presented for review and not written into the live library.

## Guardrails

- Never extract a pattern that fails any of the three bar tests; "nothing worth extracting" is the correct and common answer, not a failure.
- Never write a draft into the live skill library silently; extractions land for the user's review first.
- Never create a new skill when an existing one covers about 80% of the pattern; propose an update to that skill instead.
- Never leave project, client, or repo specifics in an extracted skill; those belong in a repo-local runbook.

## Output contract

Either a one-line "nothing worth extracting" with the reason, or: a one-sentence pattern statement, an explicit per-test verdict against recurring / non-obvious / codifiable, a new-skill-versus-update-existing decision (naming the overlapping skill if any), and a sanitized draft in the library's standard format presented for review — never written into the live library.

## Verification standard

Do not call the task done until: the qualify check ran, the candidate pattern (if any) was tested against all three bar criteria with an explicit verdict for each, the existing library was checked for 80% overlap before any new draft, specifics were stripped into a runbook rather than left in the skill, and any draft was presented for review rather than committed live. Acceptance test: evaluate this session's own work for an extractable pattern and show the reasoning either way.
