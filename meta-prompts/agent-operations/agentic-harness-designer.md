<prompt>
  <task>
    Create a new skill for my AI coding agent called "agentic-harness-designer", stored
wherever my harness loads skills from.

The skill's job: when I'm designing or reviewing an agent-powered system or product,
walk the real architecture questions and produce a phased plan — treating the problem
as an agent-SYSTEM problem, not a model-choice problem.

The skill must include: (1) trigger conditions — designing, evaluating, or debugging
any AI-agent-powered product, tool, or serious automation; (2) the design walk, in
order: what tools the agent gets and their exact contracts; the permission model
(what's autonomous, what needs approval, what's forbidden); workflow state and
durability (what survives a crash or restart); context and memory strategy (what the
agent knows, from where, and what it must not accumulate); evaluation (how we'll know
it works — concrete checks, not vibes); observability (what's logged, what the
operator can see mid-run); (3) failure-mode review against the common killers: missing
approval gates, non-durable state, unbounded context growth, no evals, invisible
execution; (4) output: a design doc with decisions and rationale, plus a phased
implementation plan where each phase is independently shippable and testable.

After writing it, test it by reviewing an agent system or automation I describe — or
one we've already built — and showing me the design doc.
</task>
</prompt>
