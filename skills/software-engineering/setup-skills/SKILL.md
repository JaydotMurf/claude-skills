---
name: setup-skills
description: Configure a repo for the engineering skills — set up its issue tracker, triage label vocabulary, and domain doc layout. Run once before first use of the other engineering skills. Use when the user explicitly runs /setup-skills or another skill says the configuration is missing.
tags: [engineering, setup, configuration]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
source: mattpocock
standard: upstream-vendored
---

# Setup Skills

Scaffold the per-repo configuration that the engineering skills assume:

- Issue tracker — where issues live.
- Triage labels — the strings used for the five canonical triage roles.
- Domain docs — where `CONTEXT.md` and ADRs live, and the consumer rules for reading them.

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Steps

### Step 1 — Explore the repo

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

- `git remote -v` and `.git/config` — is this a GitHub repo? Which one?
- `AGENTS.md` and `CLAUDE.md` at the repo root — does either exist? Is there already an `## Agent skills` section?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root.
- `docs/adr/` and any `src/*/docs/adr/` directories.
- `docs/agents/` — does prior skill output already exist here?
- `.scratch/` — sign that a local-markdown issue tracker convention is already in use.

### Step 2 — Present findings and ask one section at a time

Summarise what's present and what's missing. Then walk the user through the three decisions one at a time — present a section, get the answer, then move to the next.

Assume the user does not know what these terms mean. Each section starts with a short explainer (what it is, why these skills need it, what changes if they pick differently).

Section A — Issue tracker.

Explainer: "The issue tracker is where issues live for this repo. Skills like `/to-issues`, `/triage`, and `/to-prd` need to know whether to call `gh issue create`, write a markdown file under `.scratch/`, or follow some other workflow."

Default posture: if a `git remote` points at GitHub, propose GitHub. If it points at GitLab, propose GitLab.

Options:
- GitHub — uses the `gh` CLI.
- GitLab — uses the `glab` CLI.
- Local markdown — issues live as files under `.scratch/<feature>/`.
- Other (Jira, Linear, etc.) — ask the user to describe the workflow in one paragraph.

For GitHub and GitLab only, ask one follow-up about whether external PRs are a triage surface.

Section B — Triage label vocabulary.

Explainer: "When `/triage` processes an issue, it applies labels matching the five canonical roles. If your repo uses different label names, map them here."

The five canonical roles and their defaults:
- `needs-triage`
- `needs-info`
- `ready-for-agent`
- `ready-for-human`
- `wontfix`

Ask if the user wants to override any.

Section C — Domain docs.

Explainer: "Some skills read `CONTEXT.md` and `docs/adr/` for domain language and past decisions."

Confirm the layout:
- Single-context — one `CONTEXT.md` + `docs/adr/` at the repo root. Most repos.
- Multi-context — `CONTEXT-MAP.md` at the root pointing to per-context files.

### Step 3 — Confirm and let the user edit

Show a draft of:
- The `## Agent skills` block to add to `CLAUDE.md` or `AGENTS.md`.
- The contents of `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md`.

Let the user edit before writing anything.

### Step 4 — Write the config files

Pick which file to edit:
- If `CLAUDE.md` exists, edit it.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create — don't pick for them.

Never create `AGENTS.md` when `CLAUDE.md` already exists, or vice versa. If an `## Agent skills` block already exists, update it in place rather than appending a duplicate.

The `## Agent skills` block:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked, plus whether external PRs are a triage surface]. See `docs/agents/issue-tracker.md`.

### Triage labels

[one-line summary of the label vocabulary]. See `docs/agents/triage-labels.md`.

### Domain docs

[one-line summary of layout — "single-context" or "multi-context"]. See `docs/agents/domain.md`.
```

Then write the three docs files using the seed templates in [references/](references/) as a starting point. For "other" issue trackers, write `docs/agents/issue-tracker.md` from scratch using the user's description.

### Step 5 — Tell the user what's now configured

Confirm setup is complete and which engineering skills will now read from these files. Mention they can edit `docs/agents/*.md` directly later — re-running this skill is only necessary if they want to switch issue trackers or restart from scratch.

## Guardrails

- Never overwrite an existing `## Agent skills` block — update it in place.
- Never create `AGENTS.md` when `CLAUDE.md` already exists, or vice versa.
- Never write the config files without showing the user the draft first.
