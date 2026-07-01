# agent-skills

[![CI](https://github.com/JaydotMurf/agent-skills/actions/workflows/ci.yml/badge.svg)](https://github.com/JaydotMurf/agent-skills/actions/workflows/ci.yml)
[![View on GitHub](https://img.shields.io/badge/GitHub-JaydotMurf%2Fagent--skills-blue?logo=github)](https://github.com/JaydotMurf/agent-skills)

A personal, open library of reusable agent skills and runbooks. Each skill is a single markdown file that any harness reading the `SKILL.md` convention can load and run — Claude Code, Codex, Gemini Antigravity, and others.

## Why this exists

This is my working arsenal of agentic procedures: the tasks I repeat as a senior engineer and want an agent to perform the same way every time, across projects and tools. It builds on the Open Skills framework and its conventions for how a skill file and a runbook should be structured, so each procedure is explicit, inspectable, and portable rather than trapped in one machine's system prompt.

Most agent setups keep their knowledge in one sprawling system prompt that gets re-explained every session and rewritten for every tool. This library captures that knowledge as small, verifiable procedures instead. A prompt is something you say once; a skill is something your agent knows how to do from now on. The repo is public because the procedures are general, and sharing them costs nothing.

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

- Anyone who wants a version-controlled way to give their agents repeatable procedures instead of re-explaining a setup every session.
- Engineers working across several AI tools and data-heavy workflows — transfer, extraction, and transformation pipelines — who want their agent procedures captured, inspectable, and portable.
- Anyone who finds a skill here useful: everything is open and copies into any harness.

## Contributing

Contributions are welcome. A skill should be self-contained and general — no classified content, no org-specific tooling — so it works for anyone who installs it. See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process and the required skill structure.

---

Built by [JaydotMurf](https://github.com/JaydotMurf).
