# agent-skills — project-level instructions

This file is the project-level version of the root CLAUDE.md, loaded automatically when an agent harness opens in this directory. Content is identical to the root CLAUDE.md; this copy ensures the harness picks it up regardless of which directory is active.

---

# agent-skills

Public library of reusable agent skills and runbooks for veterans and GovTech professionals. The skills are model-agnostic: each is a canonical markdown procedure that runs on any agent harness reading a `SKILL.md` convention (Claude Code, Codex, Gemini Antigravity, and others). Every file in this repo is a skill, a runbook, a template, a build prompt, or documentation for how to use and contribute them.

---

## Writing rules

- No bold formatting inside prose.
- No bullet points longer than one sentence.
- No rhetorical openers ("In today's fast-paced world...").
- No AI-isms: leverage, utilize, seamlessly, robust, cutting-edge.
- Write the way a senior engineer writes documentation: precise, direct, human.

---

## Skill authoring standard

A skill is a primitive: one atomic, repeatable action an agent can perform and verify on its own. Every skill in this repo must have:

1. Frontmatter at the top: `name`, `description`, `tags`, `audience`. Add `source` when the skill is imported (for example `open-skills` or `mattpocock`).
2. A trigger description: the exact conditions under which the agent should invoke this skill, and the conditions under which it should not.
3. Numbered steps the agent follows in order.
4. At least one guardrail: a hard constraint the agent must never violate while the skill is active, written as a "Never..." imperative.
5. An output contract: what the skill produces and in what shape.
6. A verification standard: the evidence that must exist before the skill calls itself done.

Skills without all six are not merge-ready.

---

## Runbook authoring standard

A runbook is a composition: an ordered chain of skills directed at one outcome. Every runbook in this repo must have:

1. Frontmatter at the top: `name`, `description`, `tags`, `audience`.
2. The outcome the runbook produces.
3. The ordered list of skills it calls, each named, with the data passed between steps.
4. A verification standard for the final output.

The runbook owns sequence and data flow. Each step it names must be an independently verifiable skill that already exists in the library.

---

## Repository structure

Skills are grouped by function into eight categories under `skills/`:

- `core-infrastructure/` — the primitives other skills call; build these first.
- `research-and-thinking/` — turn raw inputs into structured, reviewable thinking.
- `writing-voice-and-content/` — make agent writing sound like a specific person for a specific audience.
- `web-publishing-and-frontend/` — take agent output public with taste and verification.
- `video-and-media-production/` — the heaviest media skills in the library.
- `testing-and-quality/` — make agent-built things trustworthy and the next session smarter.
- `agent-operations/` — meta-skills about running agents well.
- `software-engineering/` — design, build, and ship code: architecture, domain modeling, prototyping, and the planning-to-issues flow.

Skills imported from an external library carry a `source:` field in their frontmatter (for example `mattpocock` or `agent-native`), and vendored skills kept close to upstream carry `standard: upstream-vendored`. These are not held to this repo's six-element authoring standard until they are adopted natively.

Runbooks live under `runbooks/`. The build prompts that generate each skill live under `meta-prompts/`, mirroring the category layout. Templates live under `templates/`.

Category nesting is a library concern. When a skill is installed into a specific harness, the nesting flattens to that harness's expected location; generating those per-harness adapters is a planned later phase, not a current requirement.

---

## File naming convention

All lowercase, hyphens, no spaces. No camelCase, no underscores.

Correct: `core-infrastructure/starting-project-session/SKILL.md`
Incorrect: `StartingProjectSession/skill.md`, `starting_project_session/SKILL.md`
