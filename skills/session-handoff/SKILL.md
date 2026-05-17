---
name: session-handoff
description: Captures key decisions, open loops, and next steps at the end of a Claude Code session so they survive context resets and can be loaded cleanly at the start of the next session.
tags: [session-management, handoff, continuity]
audience: DoD contractors, veterans, solo operators running multi-session projects
status: coming-soon
---

# Session Handoff

This skill is under development.

When complete, `session-handoff` will give Claude a structured end-of-session routine: capturing what was decided, what was left open, what changed, and what comes next — then writing that summary to a file that `starting-project-session` can load at the start of the next session. The goal is to make context resets a non-event rather than a tax on productivity, so work across sessions stays continuous without requiring the user to re-orient Claude from scratch each time.
