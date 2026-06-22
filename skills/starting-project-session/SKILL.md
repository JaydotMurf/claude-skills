---
name: starting-project-session
description: Loads project context at the start of a fresh coding agent session by reading implementation plans and design docs, confirming the current phase, next step, and files to touch — then waiting for explicit go-ahead before taking any action. Use at the top of any session where prior context may have been lost, when the user says "pick up where we left off", "fresh session", "load context", "what's next", "resume the build", "let's get started on the project", or explicitly runs /init. Always trigger before any coding or editing begins.
allowed-tools: Read
---

# Starting a Project Session

Structured warm-up for any coding agent session. Orients to the current project state before any action is taken. Follow steps in order — do not skip ahead.

## Startup sequence

### Step 1 — Initialize (Claude Code only)

If running in Claude Code, run `/init` to load `CLAUDE.md` and establish project-level instructions. If `/init` fails or `CLAUDE.md` is missing, note it and continue to Step 2. On other platforms, skip to Step 2.

### Step 2 — Locate and read the project docs

Check for these files in priority order:

| File                          | Purpose                                                                     |
| ----------------------------- | --------------------------------------------------------------------------- |
| `docs/implementation-plan.md` | Phase roadmap and current step                                              |
| `docs/design-guidelines.md`   | Design decisions and constraints                                            |
| `.antigravity.md`             | Project-level instructions (Antigravity — takes precedence over AGENTS.md) |
| `AGENTS.md`                   | Project-level instructions (Antigravity primary / cross-platform standard)  |
| `CLAUDE.md`                   | Project-level instructions (Claude Code)                                    |
| `GEMINI.md`                   | Project-level instructions (legacy Gemini CLI)                              |
| `README.md`                   | Fallback if no implementation plan exists                                   |

Read any of the above that are present. Do not skip a file because it is platform-specific — in a cross-platform project multiple config files may coexist and each may contain relevant constraints.

### Step 3 — Confirm project state

After reading, output a confirmation block using this exact format:
Phase : [phase name and number, as written in the docs]
Next : [the specific next step listed in the implementation plan]
Files : [each file to be created or modified — full paths]

Rules for the confirmation block:

- Use the project's own terminology. Do not invent phase names.
- List actual file paths, not vague descriptions.
- If the docs are ambiguous about what comes next, flag it explicitly — do not guess.

### Step 4 — Wait for explicit go-ahead

After the confirmation block, append this verbatim:
Let me know if you understand what the task is before making edits.
Tell me what you are going to do, step by step, and wait for my approval.

Stop here. Do not write code, edit files, or run terminal commands until the user explicitly approves.

## Guardrails

- Never begin coding, editing, or running commands before the user has approved in Step 4.
- Never summarize docs — confirm state precisely as the docs describe it.
- Never infer a "next step" if the implementation plan doesn't explicitly state one. Flag ambiguity instead.
- If `/init` errors, note it in the output and continue — do not abort the startup sequence.
