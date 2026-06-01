# Changelog

All notable changes to this project are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [1.1.0] — 2026-06-01

### Changed

- Renamed meta-prompt-composer to prompt-builder for clarity with a
  non-technical audience.
- Implemented progressive disclosure in prompt-builder: extracted inline
  example from SKILL.md into references/examples.md. SKILL.md now
  references the file rather than embedding the content.

---

## [1.0.0] — 2026-05-17

### Added

- `starting-project-session` skill: structured session warm-up that loads project context, reads implementation plans and design docs, confirms the current phase and next step, and waits for explicit go-ahead before any action is taken.
- `meta-prompt-composer` skill: turns raw notes and constraints into a structured, reusable prompt with Role, Instructions, Output format, and Guardrails sections — no prompt engineering background required.
- `session-handoff` skill stub: placeholder for a coming-soon end-of-session routine that captures decisions, open loops, and next steps so they survive context resets.
- `templates/SKILL-TEMPLATE.md`: commented template for contributors building new skills, covering all required frontmatter and sections.
- `INSTALLATION.md`: three install methods — global, project-level, and auto-invoke on session start.
- `CONTRIBUTING.md`: submission process, required skill structure, and acceptance criteria.
- `CODE_OF_CONDUCT.md`: Contributor Covenant 2.1.
