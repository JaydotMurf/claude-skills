---
name: agentic-harness-designer
description: When designing, evaluating, or debugging an agent-powered system, walk the real architecture questions in order — tool contracts, permission model, state durability, context and memory, evaluation, observability — then review against the common failure modes and produce a design doc plus a phased plan where each phase is independently shippable and testable. Treats the work as an agent-system problem, not a model-choice problem. Trigger when designing, evaluating, or debugging any AI-agent-powered product, tool, or serious automation.
tags: [agent-operations, architecture, agent-systems, design]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Agentic Harness Designer

Agent systems fail at the system level, not the model level. The model is rarely the reason a deployed agent misbehaves; the reasons are missing approval gates, state that does not survive a restart, context that grows without bound, no way to tell if it works, and execution nobody can see. This skill walks those architecture questions in order and produces a design doc and a phased plan, holding the focus on the harness rather than the model choice.

## When to use this skill

Invoke it when:

- The user is designing a new AI-agent-powered product, tool, or serious automation.
- The user is evaluating or reviewing an agent system, theirs or someone else's.
- The user is debugging an agent system that misbehaves and the cause is likely architectural.

Do not invoke it for a one-shot prompt with no tools, autonomy, or persistence, for a pure model-selection or prompt-wording question, or for a trivial script that happens to call an LLM once. This skill is for systems where the agent acts over time with tools and state; if there is no system, there is nothing to design.

## Reframe first

State the framing before the walk: this is an agent-system problem, not a model-choice problem. If the user is anchored on which model to use, redirect to the system questions below — the model is one swappable component, not the architecture. Keep this framing for the whole walk.

## The design walk

Walk these questions in order. Each produces a decision with a rationale that lands in the design doc.

### Step 1 — Tools and their contracts

Enumerate every tool the agent gets, and for each, the exact contract: inputs, outputs, side effects, failure behavior. A tool with a fuzzy contract is where the agent will eventually do something unexpected. Completion: a list of tools each with an exact input/output/side-effect contract.

### Step 2 — Permission model

Define what the agent may do autonomously, what requires human approval, and what is forbidden outright. Be explicit about the boundary — anything irreversible or outward-facing belongs behind an approval gate or in the forbidden set. Completion: every capability is classified autonomous, approval-gated, or forbidden.

### Step 3 — Workflow state and durability

Decide what state the workflow holds and what survives a crash or restart. An agent whose state lives only in memory loses everything on a restart mid-run; decide what must be persisted and where. Completion: a statement of what state persists, where, and what a restart recovers.

### Step 4 — Context and memory strategy

Decide what the agent knows, from where, and — just as important — what it must not accumulate. Unbounded context growth is a slow failure: it degrades quality and inflates cost until the system breaks. Define the bounds. Completion: a context and memory plan with explicit bounds on growth and a statement of what must not be accumulated.

### Step 5 — Evaluation

Define how anyone will know the system works, as concrete checks, not vibes. Name the specific things that must be true and how each is measured. A system with no evals cannot be improved or trusted. Completion: a concrete evaluation plan with measurable checks.

### Step 6 — Observability

Define what is logged and what the operator can see mid-run. An agent whose execution is invisible cannot be supervised or debugged when it goes wrong. Completion: a statement of what is logged and what is visible to the operator during a run.

## Failure-mode review

Before writing the plan, review the design against the common killers and state, for each, whether the design addresses it: missing approval gates, non-durable state, unbounded context growth, no evals, and invisible execution. Any unaddressed killer is a gap to fix before the design is done, not a footnote.

## Phased plan

Produce a phased implementation plan where each phase is independently shippable and testable on its own — not a single big-bang build. Each phase names what it delivers and how that phase is verified. Completion: an ordered set of phases, each independently shippable and testable.

## Guardrails

- Never let the design collapse into a model-choice discussion; the model is a swappable component, and the architecture is the six system questions.
- Never finish a design with an unaddressed common killer; missing approval gates, non-durable state, unbounded context, no evals, or invisible execution each block the design until addressed.
- Never produce a big-bang plan; every phase must be independently shippable and testable.
- Never leave a tool with a fuzzy contract; each tool's inputs, outputs, side effects, and failure behavior are stated exactly.

## Output contract

A design doc that records, in order, decisions and rationale for tool contracts, the permission model, state durability, context and memory strategy, evaluation, and observability; a failure-mode review stating how the design handles each of the five common killers; and a phased implementation plan where each phase is independently shippable and testable.

## Verification standard

Do not call the task done until: all six design-walk questions have a decision with a rationale, every tool has an exact contract, the permission model classifies every capability, state durability and context bounds are stated, the evaluation plan is concrete and measurable, observability is defined, the failure-mode review addresses all five killers, and the plan's phases are each independently shippable and testable. Acceptance test: review an agent system or automation the user describes (or one already built) and produce the design doc.
