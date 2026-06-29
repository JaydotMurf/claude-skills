<prompt>
<task>
Create a new skill for my AI coding agent called "radio-edit", stored wherever my
harness loads skills from.

The skill's job: produce a transcript-driven rough cut of talking-head footage — fix
the spoken flow first, before any visual work.

This depends on my media-transcription skill: input is a video plus its word-level
timestamped transcript.

Before writing it, interview me for: my editing software (for the right timeline
format — FCXML or EDL), how aggressive cuts should be by default (tight vs.
conversational), and whether anything must always be cut (profanity, specific
phrases, names).

The skill must include: (1) trigger conditions — when I ask for a rough cut, paper
edit, or cleaned-up edit of a recording; (2) edit-decision rules: detect false starts,
repeated takes (keep the best, with reasoning), filler, dead air, and tangents;
(3) a paper edit document for my review: every cut with timecodes, what was removed,
and why — delivered BEFORE the timeline file; (4) timeline export in my NLE's format
with cuts placed, including a small handle of frames on each cut for finesse;
(5) a revision loop: I mark up the paper edit, you regenerate the timeline.

After writing it, test it on a short recording (under 5 minutes) end to end, including
importing the timeline into my editor.
</task>
</prompt>
