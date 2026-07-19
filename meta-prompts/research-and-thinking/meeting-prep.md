<task>
Create a new skill for my AI coding agent called "meeting-prep", stored wherever my
harness loads skills from.

The skill's job: prepare me for a meeting before it happens — turn whatever context
exists on the attendees and the history into explicit goals, the questions that serve
those goals, the likely landmines, and a short prep checklist. It is the pre-meeting
counterpart to meeting-synthesis (which handles the after).

The skill must include: (1) trigger conditions — "prep me for this meeting", "I have a
meeting with...", "help me get ready for", or a named upcoming meeting that matters — and
non-triggers: not a routine standup with nothing at stake, not a meeting that already
happened (meeting-synthesis owns that); if the goal itself is unclear, route to
intention-clarifier first; (2) a basics step (what, who, when, why) that reads my notes
or files rather than asking when the answer is on disk; (3) a context refresh on the
attendees — last interaction, relevant history and open threads, each attendee's likely
priorities — drawn from existing notes and prior meeting syntheses, asking only for what
no source holds; (4) explicit meeting-specific goals, two or three, specific enough that
I could tell afterward whether each was met, plus the information I need to leave with;
(5) goal-linked questions in ask-order, not a generic agenda; (6) a landmines section —
sensitive topics and probable disagreements, each with a one-line handling read; (7) a
short preparation-task checklist.

Write it to the open-skills authoring standard: six elements (frontmatter, trigger
description, numbered steps, a "Never..." guardrail, an output contract, a verification
standard), prose-heavy, no inline bold, no AI-isms, and lane-neutral (no employer or
project specifics).
</task>
