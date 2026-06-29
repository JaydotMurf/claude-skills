---
name: meeting-synthesis
description: Turn a meeting transcript or recording into a structured, actionable synthesis — takeaways, decisions with their decider, action items with owner and deadline, open questions, and durable context — synthesized per topic and keeping what was said strictly separate from what was inferred. Use for any meeting transcript, recording, or "what happened in this meeting" request.
tags: [research-and-thinking, meetings, synthesis, notes]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Meeting Synthesis

A raw transcript is a chronological wall of speech. What the user needs is the opposite: the decisions, the commitments, and the open threads, organized by topic and stripped of filler — without quietly turning "someone mentioned" into "the team decided". This skill does that conversion under a hard line between recorded fact and inference.

## When to use this skill

Invoke it when:

- The user shares a meeting transcript or a recording of a meeting.
- The user asks "what happened in this meeting", "summarize this call", or "pull the action items".

If the input is a recording rather than text, transcribe it first with the media-transcription skill, then run this on the transcript. Do not invoke this skill for a one-on-one chat with no decisions or commitments, or for a document that is not a meeting; there is nothing to synthesize.

## Saved defaults

These are the assumed interview answers, recorded here because the build ran without a live interview. Change them in place if they are wrong.

- Synthesis destination: `~/Documents/notes/meetings/`, one Markdown file per meeting named `YYYY-MM-DD-<slug>.md`, where the slug names the meeting.
- Action items destination: kept inside the synthesis under their own heading and also appended to a running `~/Documents/notes/tasks.md`, each line carrying owner, deadline, and a back-link to the meeting file. No external task tool or email-draft integration was named, so none is assumed; if the user later names a task tool, route the same lines there instead.

## Steps

### Step 1 — Get a clean transcript

If the input is text, use it directly. If it is a recording, transcribe it with the media-transcription skill first. Confirm speaker labels are present where the source has them; you need them to attribute decisions. Completion: you hold a readable transcript with speakers identifiable where the source allowed.

### Step 2 — Map the topics

Read the transcript and list the distinct topics discussed, ignoring chronology. A topic is a subject the group actually worked on, not every passing mention. The synthesis is organized by these topics, not by the order things were said.

### Step 3 — Synthesize each topic into the fixed structure

For each topic, produce these sections in this order:

- Takeaways: the substance of what was covered, in plain statements.
- Decisions: each decision made, with who decided it. If no one clearly decided, say so rather than inventing a decider.
- Action items: each commitment, with owner and deadline where stated. Where the owner or deadline was not stated, write "owner not stated" or "no deadline stated" — do not assign one.
- Open questions: what was raised and left unresolved.
- Durable context: facts, constraints, or background worth keeping beyond this meeting.

### Step 4 — Separate what was said from what you inferred

Keep recorded fact and inference visibly apart. Anything drawn from the transcript stands as a plain statement. Anything you concluded that was not stated is marked, for example "(inferred)". When you are unsure whether something was decided or merely discussed, treat it as discussed, not decided.

### Step 5 — Preserve exact quotes for the load-bearing moments

For anything contentious or commitment-shaped — a firm commitment, a disagreement, a deadline someone owned, a reversal — quote the speaker's exact words and attribute them, rather than paraphrasing. Paraphrase is fine for routine content; it is not fine for the moments someone might later be held to.

### Step 6 — Write the synthesis and route the action items

Write the per-topic synthesis to `~/Documents/notes/meetings/YYYY-MM-DD-<slug>.md`. Append each action item to `~/Documents/notes/tasks.md` with its owner, deadline, and a link back to the meeting file. Tell the user the synthesis path and the count of decisions and action items captured.

## Guardrails

- Never present an inference as something that was said; inferences are marked, and unstated owners or deadlines are named as unstated.
- Never invent a decider, an owner, or a deadline that the transcript does not contain.
- Never paraphrase a contentious or commitment-shaped statement; quote it exactly and attribute it.
- Never organize the synthesis chronologically when the meeting covered multiple topics; synthesize per topic.

## Output contract

A Markdown file at `~/Documents/notes/meetings/YYYY-MM-DD-<slug>.md` organized by topic, each topic carrying Takeaways, Decisions (with decider), Action items (with owner and deadline or an explicit "not stated"), Open questions, and Durable context, with inferences marked and contentious or commitment-shaped moments preserved as attributed quotes. Action items are also appended to `~/Documents/notes/tasks.md`. The chat reply states the synthesis path and the decision and action-item counts.

## Verification standard

Do not call the task done until: every topic in the meeting has its own section, every decision names a decider or states none was clear, every action item carries an owner and deadline or an explicit "not stated", every inference is marked, every contentious or commitment-shaped moment is a quote, and the file exists at the stated path. Test by running it on one real transcript and showing the synthesis. Build-time note: no sample transcript was supplied at build time, so the first real invocation is the acceptance test.
