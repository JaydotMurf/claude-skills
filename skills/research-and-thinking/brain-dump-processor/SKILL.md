---
name: brain-dump-processor
description: Process messy multi-topic input — voice memo transcripts, brain dumps, rambling notes — into cleanly separated, individually evaluated ideas, each with context, an honest worth-pursuing assessment, and a concrete next step. Use whenever the user shares a voice transcript or brain dump, or says "process this".
tags: [research-and-thinking, ideation, notes, triage]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Brain Dump Processor

A brain dump is one stream carrying several ideas tangled together. Summarizing it back into one paragraph destroys the value. This skill pulls the distinct ideas apart, evaluates each one honestly, and files them where they can be acted on later.

## When to use this skill

Invoke it when:

- The user shares a voice memo transcript, a brain dump, or a block of rambling notes.
- The user says "process this", "sort this out", or "what's in here".
- A single message contains several half-formed ideas mixed with context and asides.

Do not invoke it for a single clear request, a question with one answer, or text that is already structured (a spec, a list, a plan). Those do not need separating; act on them directly.

## Saved defaults

These are the assumed interview answers, recorded here because the build ran without a live interview. Change them in place if they are wrong.

- Filing destination: a folder of dated notes at `~/Documents/notes/ideas/`, one Markdown file per processing run named `YYYY-MM-DD-<slug>.md`. Chosen over a single inbox file because separated ideas stay readable as the pile grows, and over an external tool because no specific tool was named and files work in any harness offline.
- Evaluation lens: the user is a DoD contractor / veteran / solo operator working in GovTech, so ideas tend to be about consulting work, GovTech product and process, veteran-services delivery, and building reusable agent skills and automation. Assess each idea against effort versus payoff for a solo operator, fit with that body of work, and whether it is already half-built somewhere.

## Steps

### Step 1 — Read the whole dump before cutting it

Read the entire input first. Do not start extracting from the top; the same idea often appears in two places, and the real point of an early ramble sometimes only lands at the end. Completion: you can name every distinct idea in the dump.

### Step 2 — Separate genuinely distinct ideas

Split the dump into separate ideas, one per actual idea — not one per paragraph and not one for the whole dump. Two mentions of the same thing collapse into one idea. A single sentence that contains two unrelated thoughts splits into two. The test is whether each piece could be acted on independently of the others.

### Step 3 — Extract each idea in the fixed format

For every distinct idea, produce exactly these four fields:

- Idea: the idea in one plain sentence.
- Context: the surrounding detail from the dump that gives it meaning — what triggered it, what it connects to, any constraint mentioned.
- Assessment: an honest read on whether it is worth pursuing and why. Say "probably not worth it" when that is true. Name the effort, the payoff, and the risk. Do not inflate a weak idea to be encouraging.
- Next step: one concrete, small action that moves it forward, or an explicit "park it" if the honest assessment is that it should wait.

### Step 4 — Flag internal contradictions

Scan across the extracted ideas for places where the dump contradicts itself — a plan stated one way early and another way later, a commitment and its reversal, two incompatible assumptions. Call each contradiction out explicitly under the ideas it sits between, naming both sides. Do not silently pick the one that sounds better.

### Step 5 — File the result

Write the processed ideas to `~/Documents/notes/ideas/YYYY-MM-DD-<slug>.md`, where the slug names the dump's dominant theme. Lead the file with a one-line date and source note, then the contradictions section if any exist, then one section per idea in the Step 3 format. Tell the user the path and give a one-line count of ideas found and contradictions flagged.

## Guardrails

- Never compress the dump into a single summary; the job is to separate ideas, not to blend them into mush.
- Never soften an honest assessment to be encouraging; a weak idea must be named as weak with its reason.
- Never resolve a contradiction silently by keeping only one side; surface both and leave the choice to the user.
- Never invent an idea that is not in the dump to round out the list.

## Output contract

A dated Markdown file at `~/Documents/notes/ideas/YYYY-MM-DD-<slug>.md` containing: a one-line source note; a contradictions section when contradictions exist; and one section per distinct idea, each with Idea, Context, Assessment, and Next step. The chat reply states the file path, the number of ideas, and the number of contradictions.

## Verification standard

Do not call the task done until: every distinct idea in the input appears exactly once in the output, every idea carries all four fields, every contradiction in the dump is flagged, and the file exists at the stated path. Test by running it on one real note or transcript the user provides and showing the resulting file before declaring it done. Build-time note: no sample dump was supplied at build time, so the first real invocation is the acceptance test.
