# agent-skills

[![CI](https://github.com/JaydotMurf/agent-skills/actions/workflows/ci.yml/badge.svg)](https://github.com/JaydotMurf/agent-skills/actions/workflows/ci.yml)
[![View on GitHub](https://img.shields.io/badge/GitHub-JaydotMurf%2Fagent--skills-blue?logo=github)](https://github.com/JaydotMurf/agent-skills)

Version-controlled, model-agnostic procedures for AI agents. Each skill is a single markdown file that any harness reading the `SKILL.md` convention can load and run — Claude Code, Codex, Gemini Antigravity, and others. Built for veterans, DoD contractors, and GovTech professionals who need AI procedures they can hand off, inspect, and trust.

## Why this exists

Most agent setups keep their knowledge in one sprawling system prompt that gets re-explained every session and rewritten for every tool. This library packages recurring agent work as small, verifiable procedures instead. A prompt is something you say once; a skill is something your agent knows how to do from now on.

## What's inside

58 skills across eight categories, chained into 7 runbooks.

- A skill is a primitive: one atomic, repeatable action, with a trigger that says when to use it and when not, numbered steps, a hard guardrail, the output it produces, and the evidence required before it calls itself done.
- A runbook is a composition: an ordered chain of skills directed at one outcome. A skill answers what an agent can do; a runbook answers what the system can reliably produce.

## Structure

Skills are grouped by function into eight categories under [`skills/`](skills/):

| Category | What it holds |
|---|---|
| [core-infrastructure](skills/core-infrastructure/) | The primitives other skills call: transcription, search, image generation, file ingestion, HTML artifacts. |
| [research-and-thinking](skills/research-and-thinking/) | Turn raw inputs into structured, reviewable thinking. |
| [writing-voice-and-content](skills/writing-voice-and-content/) | Make agent writing sound like a specific person for a specific audience. |
| [web-publishing-and-frontend](skills/web-publishing-and-frontend/) | Take agent output public with taste and verification. |
| [video-and-media-production](skills/video-and-media-production/) | Transcript-driven rough cuts, motion-graphics pipelines, and NLE scripting. |
| [testing-and-quality](skills/testing-and-quality/) | Make agent-built things trustworthy and the next session smarter. |
| [agent-operations](skills/agent-operations/) | Meta-skills about running agents well: delegation, handoff, skill extraction. |
| [software-engineering](skills/software-engineering/) | Architecture, domain modeling, prototyping, and the planning-to-issues flow. |

Runbooks live under [`runbooks/`](runbooks/). The build prompts that generate each skill live under [`meta-prompts/`](meta-prompts/). Templates live under [`templates/`](templates/).

## Built to be trusted

Three properties keep the library auditable rather than a black box:

- Every skill states its proof standard up front, so "done" means evidence exists, not that the agent produced confident language.
- Skills never store secrets; each reads its API key from `~/.config/agent-skills/.env` at runtime, with only the [`.env.example`](.env.example) contract committed.
- Quality is enforced in three tiers: a deterministic CI gate over every skill, behavioral evals for the highest-value skills and all runbooks, and a live-run [verification ledger](docs/verification-ledger.md) recording real cost for the API-backed skills. See [CONTRIBUTING.md](CONTRIBUTING.md) for the details.

## Install

See [INSTALLATION.md](INSTALLATION.md) for three install methods: global, project-level, and auto-invoke on session start.

## Who this is for

- Veterans new to AI-assisted workflows who want a structured starting point, not a blank prompt box.
- DoD contractors who need documented, repeatable AI operating procedures they can hand off or audit.
- Solo operators running several projects across more than one agent tool who can't afford to re-explain their setup every session.

## Contributing

Skills submitted here must work for a DoD contractor or veteran without modification: no classified content, no org-specific tooling. See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process and the required skill structure.

---

Built by [JaydotMurf](https://github.com/JaydotMurf) · [Tactical Asset](https://tacticalasset.co) — helping veterans land six-figure GovTech roles.
