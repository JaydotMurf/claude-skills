<prompt>
  <task>
    Create a new skill for my AI coding agent called "session-operating-map", stored
wherever my harness loads skills from.

The skill's job: set up and maintain a repo-local operating map for projects where I
run multiple agent sessions in parallel — which lane owns what, current state,
blockers, and decisions.

The skill must include: (1) trigger conditions — when I start parallel workstreams in
a project, ask "what's in flight," or ask you to set up coordination for a repo;
(2) the map file: a single repo-local doc (suggest docs/operating-map.md) listing each
lane with a short name, its objective, owning session, current state, and blockers;
(3) lane discipline: one lane per concern, named so its purpose is obvious; (4) update
rules: a lane's entry gets updated when its state meaningfully changes — start, block,
handoff, done — not as a journal; (5) archive rules: finished lanes move to a done
section with a one-line outcome, and lessons worth keeping get promoted into the
project's docs or skills rather than dying with the lane; (6) a read-first rule: any
session joining the project reads the map before starting work.

After writing it, set up the map for my current project and populate it with what's
actually in flight.
</task>
</prompt>
