---
name: flywheel
description: The posture that runs under every other runbook — extract durable skills from sessions, bank testing discoveries where they belong, keep the global and local boundary clean, and preserve coordination state so a skill library compounds instead of leaking into chat history.
tags: [agent-operations, testing, memory, meta]
audience: operators, engineering leads, and solo builders
---

# The Flywheel

This one is different: it is not a pipeline you run on demand, it is a posture that runs under every other runbook. Its job is to make sure no useful discovery dies in chat.

## Outcome

A skill library that compounds — recurring patterns extracted into draft skills, testing discoveries banked in the repo they belong to, the global-versus-local boundary kept clean, and coordination state preserved across sessions.

## Skills it calls

1. `agent-operations/session-to-skill-extractor` — takes the just-finished session; tests it against recurring / non-obvious / codifiable and, when it passes, produces a sanitized draft skill in the library's standard format, presented for review and never written into the live library. Hands extracted procedure into the library.
2. `testing-and-quality/testing-runbook-creator` — takes any testing discovery from the session; writes it into the repo's `docs/testing-runbook.md` as a six-field entry, so the knowledge lives in the repo it belongs to. Hands the repo-local testing entry forward.
3. `testing-and-quality/page-testing-memory` — takes the testing work; keeps process detail in the skill and routes page-specific detail to the repo, holding the global and local boundary clean as both libraries grow. Hands the boundary-clean state forward.
4. `agent-operations/session-operating-map` — takes the session's coordination state; records lane ownership, state, and durable lessons in `docs/operating-map.md`, promoting lessons into docs or skills so the next session inherits them.

## Verification

- The extractor either returns a one-line "nothing worth extracting" with a reason, or a draft held for review — never a silent write into the live library.
- Any testing discovery from the session exists as a six-field entry in the repo's testing runbook, not only in chat.
- Page-specific detail lives in the repo and process detail lives in the skill, with no duplication across the boundary.
- The operating map reflects the session's final lane state, with durable lessons promoted into docs or skills.
