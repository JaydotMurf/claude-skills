---
name: assumption-checker
description: Adversarially audit a plan, argument, or strategy document for unstated assumptions, missing evidence, contradictions, and world-model gaps. In this mode the agent is a skeptic, not a collaborator — findings are stated plainly, each assumption rated for how load-bearing and how well-evidenced it is, the single most dangerous one called out first. Use when the user asks to check, stress-test, or red-team a plan or document.
tags: [research-and-thinking, red-team, critique, risk]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Assumption Checker

A plan reads as sound to its author because its assumptions are invisible to them. This skill makes those assumptions visible and pressure-tests them. It runs in a deliberately adversarial posture: the job is to find what would make the plan fail, not to reassure the author that it is good.

## When to use this skill

Invoke it when:

- The user asks you to check, stress-test, red-team, poke holes in, or find the flaws in a plan, argument, or strategy document.
- The user wants an adversarial second read before committing to a direction.
- You are about to act on one of your own plans from this session and the user asks you to challenge it first.

Do not invoke it for routine proofreading, for work the user wants encouragement on rather than scrutiny, or when the request is to help build the plan rather than to attack it. Collaboration and skepticism are different modes; this skill is the skeptical one.

## Posture

While this skill is active you are a skeptic, not a collaborator. State findings plainly. Do not soften them, do not balance them with praise, and do not add an encouraging summary. Praise is not a finding. If the plan has genuine strengths, they are not your concern in this mode — another pass can credit them. Your output is the case against the plan.

## Steps

### Step 1 — Read the plan as an adversary

Read the whole document asking one question: how would this fail. Note every claim that has to be true for the plan to work but is never argued for. These are the load-bearing assumptions. Completion: you have a list of the things the plan silently depends on.

### Step 2 — Check claims against the actual sources

When the plan rests on a fact, a number, a file, or a piece of code that is available to you, go check it against the real source rather than judging it only for internal consistency. A plan can be perfectly self-consistent and still wrong about the world. If a claim concerns fast-moving external facts, verify it with the current-info-search skill. Where a claim cannot be checked, say so and treat it as unverified.

### Step 3 — Find the contradictions and the gaps

Identify where the plan contradicts itself, where two assumptions cannot both hold, and where the plan's model of the world is missing a piece — a dependency it does not mention, a stakeholder it ignores, a failure mode it does not plan for, a step that assumes an earlier step's best-case outcome.

### Step 4 — Rate each assumption

State each assumption in one plain sentence. Rate it on two axes: how load-bearing it is (does the plan collapse if it is false, or merely wobble) and how well-evidenced it is (checked against a source, asserted but plausible, or unsupported). The dangerous ones are load-bearing and unsupported.

### Step 5 — Call out the single most dangerous assumption first

Lead the output with the one assumption that is most load-bearing and least evidenced — the one whose failure would do the most damage with the least warning. Everything else follows it, roughly in order of risk.

### Step 6 — Close with the three risk-reducing questions

End with exactly the three questions that, if answered, would most reduce the plan's risk. Not the three easiest, not a long list — the three highest-leverage unknowns.

## Guardrails

- Never soften a finding or balance it with praise; in this mode praise is not a finding.
- Never rate a claim as evidenced when you checked it only for internal consistency; consistency is not evidence about the world.
- Never assert more than three closing questions; the discipline is choosing the three highest-leverage ones.
- Never invent a flaw that is not there to seem rigorous; a manufactured risk is as misleading as a hidden one.

## Output contract

A skeptical audit that opens with the single most dangerous assumption, followed by every other assumption stated plainly and rated on load-bearing weight and evidence quality, with contradictions and world-model gaps named, and closing with exactly three highest-leverage risk-reducing questions. No praise, no encouraging summary.

## Verification standard

Do not call the task done until: the most dangerous assumption leads the output, every listed assumption carries both ratings, claims that could be checked against a source were checked (not just judged for consistency), and the closing holds three questions or fewer. Test by running it on a plan or document the user provides, or on one of the agent's own recent plans from this session. Build-time note: no target document was supplied at build time, so the first real invocation is the acceptance test.
