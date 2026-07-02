---
name: starting-project-session
description: Loads project context at the start of a fresh coding agent session by reading implementation plans and design docs and any recent handoff left by the handoff skill, confirming the current phase, next step, and files to touch — then waiting for explicit go-ahead before taking any action. Use at the top of any session where prior context may have been lost, when the user says "pick up where we left off", "fresh session", "load context", "what's next", "resume the build", "let's get started on the project", or explicitly runs /init. Always trigger before any coding or editing begins.
allowed-tools: Read, Bash
tags: [productivity, workflow, sessions]
audience: Software engineers and developers using Claude Code
---

# Starting a Project Session

Structured warm-up for any coding agent session. Orients to the current project state before any action is taken. Follow steps in order — do not skip ahead.

## When to use this skill

Use at the top of a session where prior context may have been lost — when the user says "pick up where we left off", "fresh session", "load context", "what's next", or "resume the build", or runs `/init`. Always run it before any coding or editing begins in a project that has roadmap or design docs.

Do not use it mid-session once project context is already loaded and a task is underway, and do not use it for a one-off question that needs no project orientation.

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

### Step 3 — Check for a recent session handoff

Check the OS temporary directory for a handoff left by the `handoff` skill before confirming state. Resolve the temp directory from `$TMPDIR` (falling back to `/tmp`) and the project slug from the basename of the git repo root (`git rev-parse --show-toplevel`, falling back to the current directory), then list the newest match:

    ls -t "${TMPDIR:-/tmp}"/session-handoff-<project-slug>-*.md 2>/dev/null | head -1

This mirrors the location and naming convention the `handoff` skill writes to, so the two stay in sync. If a file exists, read it: it is the most recent hand-off from a prior session, and where it conflicts with older roadmap docs it takes precedence. Carry its next-focus and its "suggested skills" into the confirmation block, and record its path. If none exists, note that and continue. This lookup is read-only and changes nothing.

### Step 4 — Confirm project state

After reading, output a confirmation block using this exact format:
Phase : [phase name and number, as written in the docs]
Next : [the specific next step listed in the implementation plan]
Files : [each file to be created or modified — full paths]
Handoff : [absolute path of the handoff read, or "none found"]

Rules for the confirmation block:

- Use the project's own terminology. Do not invent phase names.
- List actual file paths, not vague descriptions.
- If the docs are ambiguous about what comes next, flag it explicitly — do not guess.

### Step 5 — Wait for explicit go-ahead

After the confirmation block, append this verbatim:
Let me know if you understand what the task is before making edits.
Tell me what you are going to do, step by step, and wait for my approval.

Stop here. Do not write code, edit files, or run terminal commands until the user explicitly approves.

## Guardrails

- Never begin coding, editing, or running state-changing commands before the user has approved in Step 5; the only commands allowed beforehand are the read-only handoff and doc lookups in Steps 2 and 3.
- Never summarize docs — confirm state precisely as the docs describe it.
- Never infer a "next step" if the implementation plan doesn't explicitly state one. Flag ambiguity instead.
- If `/init` errors, note it in the output and continue — do not abort the startup sequence.

## Output contract

A confirmation block in the exact `Phase / Next / Files / Handoff` format, stated in the project's own terminology with real file paths, followed verbatim by the two-line go-ahead request. The `Handoff` line names the path of the most recent `session-handoff-<project-slug>-*.md` found in the OS temp directory (or "none found"), read via a read-only lookup. Where the docs are ambiguous about the next step, the ambiguity is flagged rather than guessed. No file is edited and no state-changing command is run.

## Verification standard

- The confirmation block reflects what the docs actually say: the phase and next step are drawn from the plan, and the file list is real paths, not vague descriptions.
- The OS temp directory was checked for a `session-handoff-<project-slug>-*.md` file, and the `Handoff` line reports the path read or "none found".
- The verbatim go-ahead lines are present after the block.
- No code was written, no file edited, and no state-changing command run before the user approved; only the read-only handoff and doc lookups.
