# Behavioral evals (Tier 2)

This directory holds the behavioral eval suite: the second tier of the project's
three-tier quality-test system. It measures whether following a skill or runbook
actually produces a good result, which the deterministic gate cannot judge.

## The three tiers

1. Deterministic gate (`scripts/check.sh` + `scripts/test.sh`) — static
   conformance plus offline behavioral tests of every script-bearing skill. Free,
   fast, runs on every push and pull request. This is the merge gate.
2. Behavioral evals (this directory) — an agent executes a target against a
   fixture input, then an LLM judge scores the output against a rubric drawn from
   the target's own Verification standard. Costs tokens and is non-deterministic,
   so it is deliberately kept off the pull-request gate and run on demand.
3. Live-path verification ledger (`docs/verification-ledger.md`) — dated evidence
   from real paid API round-trips, recorded per skill.

## Why evals are not on the CI gate

A rubric scored by a model is neither free nor perfectly repeatable. Gating merges
on it would make the pipeline flaky and costly. Instead the gate stays
deterministic, and evals run when a model budget is approved — locally or in a
scheduled job — producing a scored report rather than a pass/fail merge block.

## Case format

One JSON file per case under `cases/`:

```json
{
  "target": "skills/research-and-thinking/assumption-checker/SKILL.md",
  "kind": "skill",
  "fixture": "tests/evals/cases/fixtures/sample-plan.md",
  "rubric": [
    { "id": "leads-with-most-dangerous",
      "criterion": "The output opens with the single most dangerous assumption." }
  ],
  "notes": "Rubric derived from the target's Verification standard."
}
```

Each rubric criterion is one checkable statement taken from the target's
Verification standard, so the eval measures the skill against the bar the skill
sets for itself.

## Running

```bash
# validate every case is well-formed and points at a real target (free, offline)
tests/evals/run.sh --validate

# execute + judge (spends tokens; intentionally gated)
AGENT_SKILLS_EVAL=1 ANTHROPIC_API_KEY=... tests/evals/run.sh --run
```

Validation is safe to run anytime and is the check to keep green as cases grow.
The judged run is the model-backed, budget-approved step.

## Coverage today

Seeded with all seven runbooks and two exemplar skills (assumption-checker,
goal-prompt-generator). Grow it by adding a case file plus a fixture; the
validator enforces the schema. Priority for expansion: the highest-traffic skills
and any skill whose output quality is hard to judge by structure alone.
