# Agent Operations

Meta-skills: skills about running agents well. This is where heavy agent users get disproportionate returns.

7 native skills, each in its own folder as `agent-operations/<skill-name>/SKILL.md`. Build prompts that generated them live under `meta-prompts/agent-operations/`. Reconciled skills from the flat library are listed below the native set.

- [goal-prompt-generator](goal-prompt-generator/SKILL.md) — turn a plan or task into a bounded, self-contained goal prompt another session can execute autonomously and be checked against.
- [visible-delegation](visible-delegation/SKILL.md) — hand work to another agent in a named, attachable tmux session the user can watch live, then verify the goal prompt's gates before reporting success.
- [session-operating-map](session-operating-map/SKILL.md) — maintain a single repo-local map of which lane owns what, its state, and its blockers when multiple sessions run in parallel.
- [self-pr-merge](self-pr-merge/SKILL.md) — review and merge a self-authored PR with real review discipline, honest pre-merge checks, the chosen merge strategy, and worktree-safe cleanup.
- [stakeholder-update-email](stakeholder-update-email/SKILL.md) — after work ships with visible impact, write and (on confirmation) send a short, truthful update email via Resend.
- [session-to-skill-extractor](session-to-skill-extractor/SKILL.md) — at the end of a substantial session, judge against a high bar whether anything is worth codifying, and draft it for review if so.
- [agentic-harness-designer](agentic-harness-designer/SKILL.md) — walk the real architecture questions of an agent system and produce a design doc plus a phased, independently shippable plan.

## Reconciled skills

Relocated here from the flat library in the taxonomy reconciliation (Pass 1). Source is noted per skill; vendored skills carry `source:` in their frontmatter.

- [ask-workflow](ask-workflow/SKILL.md) — a router over the user-invoked skills: ask which skill or flow fits the current situation. (mattpocock)
- [handoff](handoff/SKILL.md) — compact the current conversation into a handoff document for another agent to pick up. (mattpocock)
- [writing-great-skills](writing-great-skills/SKILL.md) — reference vocabulary and principles for authoring predictable skills. (mattpocock)
- [starting-project-session](starting-project-session/SKILL.md) — load project context at session start, confirm phase, next step, and files, then wait for go-ahead. (original)
- [prompt-builder](prompt-builder/SKILL.md) — turn scattered notes into a structured four-section reusable prompt (Role, Instructions, Output format, Guardrails). (original)
- [context-to-open-brain](context-to-open-brain/SKILL.md) — extract durable, reusable knowledge from a session (decisions, scripts, structure, conventions, integrations) and push each as a standalone Open Brain capture; triggers proactively at session end. (original)
