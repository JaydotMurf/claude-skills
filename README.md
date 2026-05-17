# claude-skills

[![View on GitHub](https://img.shields.io/badge/GitHub-JaydotMurf%2Fclaude--skills-blue?logo=github)](https://github.com/JaydotMurf/claude-skills)

A curated library of Claude Code skills for veterans and GovTech professionals.

## What is a Claude Code skill?

Claude Code supports custom skills: named, structured workflows you invoke with a slash command inside a session. A skill is a markdown file that tells Claude exactly what to do — what to check, what to ask, what to output — before taking any action. Skills are reusable across projects and machines without any configuration beyond copying a folder.

## Skills

| Skill | What it does | Audience |
|---|---|---|
| [starting-project-session](skills/starting-project-session/) | Loads project context at the start of a session, confirms the current phase and next step, and waits for explicit go-ahead before touching anything | Any Claude Code user working on multi-session projects |
| [meta-prompt-composer](skills/meta-prompt-composer/) | Turns raw notes and constraints into a structured, reusable prompt with Role, Instructions, Output format, and Guardrails sections | Contractors and solo operators building repeatable AI workflows |
| session-handoff | Captures key decisions and open loops at the end of a session so nothing is lost across context resets | Coming soon |

## Install

See [INSTALLATION.md](INSTALLATION.md) for three install methods: global, project-level, and auto-invoke on session start.

## Who this is for

- Veterans new to AI-assisted workflows who want a structured starting point, not a blank prompt box.
- DoD contractors who need documented, repeatable AI operating procedures they can hand off or audit.
- Solo operators running multiple projects who can't afford to re-explain their setup to Claude every session.

## Contributing

Skills submitted to this repo must work for a DoD contractor or veteran without modification — no classified content, no org-specific tooling. See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process and required skill structure.

---

Built by [JaydotMurf](https://github.com/JaydotMurf) · [Tactical Asset](https://tacticalasset.co) — helping veterans land six-figure GovTech roles.
