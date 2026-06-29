<prompt>
  <task>
    Create a new skill for my AI coding agent called "session-to-skill-extractor", stored
wherever my harness loads skills from.

The skill's job: at the end of substantial work sessions, evaluate whether anything we
did is worth preserving as a new skill or an update to an existing one — and if so,
draft it.

The skill must include: (1) trigger conditions — when I say "wrap up," "anything worth
keeping?", or at the natural end of a session where we solved something non-trivially;
(2) a high extraction bar, stated explicitly: the pattern must be RECURRING (I'll
plausibly need it again), NON-OBVIOUS (a fresh session wouldn't just derive it), and
CODIFIABLE (it can be written as a procedure) — most sessions yield nothing, and
"nothing worth extracting" is a good answer; (3) a check against my existing skill
library first: if an existing skill covers 80% of the pattern, propose an update, not
a new skill; (4) drafts follow my skills' standard format with trigger conditions, and
land somewhere for my review — never silently into the live library; (5) a sanitize
rule: extracted skills generalize the pattern and strip project/client specifics,
which stay in repo-local runbooks.

After writing it, test it on THIS session: evaluate whether our setup work contains an
extractable pattern, and show me your reasoning either way.
</task>
</prompt>
