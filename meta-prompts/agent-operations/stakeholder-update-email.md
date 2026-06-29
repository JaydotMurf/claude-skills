<prompt>
  <task>
    Create a new skill for my AI coding agent called "stakeholder-update-email", stored
wherever my harness loads skills from.

The skill's job: after work ships with stakeholder-visible impact, send or draft a
short, truthful update email to the right person.

Before writing it, interview me for: who my recurring stakeholders are and what each
cares about, whether you should send directly (and through what — e.g. a Resend API
key in an env file) or always draft for my review, and whether I should be CC'd on
sends.

The skill must include: (1) trigger conditions — when work merges or ships with
visible impact for a stakeholder, or when I ask for an update email; (2) a gate: if
nothing stakeholder-visible changed, say so and send nothing; (3) writing rules:
describe shipped behavior in the recipient's vocabulary, not implementation detail;
never call anything done that wasn't verified; if something shipped partially, say
which part; (4) a consistent short format: what changed, what it means for them,
what's next; (5) the send/draft mechanics per my preference, with send requiring my
explicit confirmation.

After writing it, test it by drafting an update for the most recent thing I shipped.
</task>
</prompt>
