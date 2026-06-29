# agent-skills

[![View on GitHub](https://img.shields.io/badge/GitHub-JaydotMurf%2Fagent--skills-blue?logo=github)](https://github.com/JaydotMurf/agent-skills)

A curated library of reusable agent skills and runbooks for veterans and GovTech professionals. The procedures are model-agnostic: each is a canonical markdown file that runs on any agent harness reading a `SKILL.md` convention, including Claude Code, Codex, and Gemini Antigravity.

## Skills and runbooks

A skill is a primitive: one atomic, repeatable action an agent can perform and verify on its own. It is a markdown file that states when to use it, when not to, the job it owns, the tools it touches, the output it produces, and the evidence required before it calls itself done. A prompt is something you say once; a skill is something your agent knows how to do from now on.

A runbook is a composition: an ordered chain of skills directed at one outcome. A skill answers what an agent can do; a runbook answers what the system can reliably produce.

## Structure

Skills are grouped by function into seven categories under [`skills/`](skills/):

| Category | What it holds |
|---|---|
| [core-infrastructure](skills/core-infrastructure/) | The primitives other skills call; build these first. |
| [research-and-thinking](skills/research-and-thinking/) | Turn raw inputs into structured, reviewable thinking. |
| [writing-voice-and-content](skills/writing-voice-and-content/) | Make agent writing sound like a specific person for a specific audience. |
| [web-publishing-and-frontend](skills/web-publishing-and-frontend/) | Take agent output public with taste and verification. |
| [video-and-media-production](skills/video-and-media-production/) | The heaviest media skills in the library. |
| [testing-and-quality](skills/testing-and-quality/) | Make agent-built things trustworthy and the next session smarter. |
| [agent-operations](skills/agent-operations/) | Meta-skills about running agents well. |

Runbooks live under [`runbooks/`](runbooks/). The build prompts that generate each skill live under [`meta-prompts/`](meta-prompts/). Templates live under [`templates/`](templates/).

## Install

See [INSTALLATION.md](INSTALLATION.md) for three install methods: global, project-level, and auto-invoke on session start.

## Who this is for

- Veterans new to AI-assisted workflows who want a structured starting point, not a blank prompt box.
- DoD contractors who need documented, repeatable AI operating procedures they can hand off or audit.
- Solo operators running multiple projects across more than one agent tool who can't afford to re-explain their setup every session.

## Contributing

Skills submitted to this repo must work for a DoD contractor or veteran without modification: no classified content, no org-specific tooling. See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process and required skill structure.

---

Built by [JaydotMurf](https://github.com/JaydotMurf) · [Tactical Asset](https://tacticalasset.co) — helping veterans land six-figure GovTech roles.
