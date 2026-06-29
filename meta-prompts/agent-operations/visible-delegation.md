<prompt>
  <task>
    Create a new skill for my AI coding agent called "visible-delegation", stored wherever
my harness loads skills from.

The skill's job: delegate work to another agent session while keeping it visible and
supervisable — shared terminal sessions, never hidden background runs.

Before writing it, check that tmux is installed (install it if not) and confirm which
agent CLI(s) I use for delegate sessions.

The skill must include: (1) trigger conditions — when I ask you to delegate, run
something in parallel, or hand work to another agent; (2) the launch procedure: create
a named tmux session, start the delegate agent in it, and pass a goal prompt (built
with my goal-prompt-generator skill if available) — then tell me how to attach and
watch; (3) monitoring rules: check the session at sensible intervals, and define what
warrants intervention (stuck loops, scope drift, destructive commands) versus patience;
(4) a results protocol: when the delegate claims completion, run the verification
gates from the goal prompt yourself before reporting success to me; (5) cleanup —
sessions get closed, not abandoned.

After writing it, test it by delegating one small real task end to end while I watch.
</task>
</prompt>
