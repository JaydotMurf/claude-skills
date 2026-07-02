# Installation

The fastest path is the bulk installer. The manual methods below it are for installing a single skill by hand or into another harness.

The library stores skills in a taxonomy (`skills/<category>/<skill>/SKILL.md`), but Claude Code only discovers a flat directory: `~/.claude/skills/<skill>/SKILL.md` (global) or `<project>/.claude/skills/<skill>/SKILL.md` (project). The installer flattens the taxonomy into that location; the manual `cp -r` steps do the same thing one skill at a time.

---

## Method 0 — Bulk install (recommended)

Symlink every top-level skill into `~/.claude/skills` so all of them show up in a fresh Claude Code session, with the repo staying the single source of truth (edits are live):

```bash
scripts/install.sh
```

Useful flags:

- `--copy` makes standalone copies instead of symlinks (survives moving the repo, but you must re-run to pick up edits).
- `--project [DIR]` installs into `DIR/.claude/skills` (defaults to the current directory) instead of globally.
- `--force` replaces an existing hand-copied skill directory, not just an existing symlink.
- `--dry-run` prints what it would do and changes nothing; `--list` prints the installable skills; `--uninstall` removes the ones this repo installed.

Nested sub-skills (for example `frontend-taste/<sub>/SKILL.md`) install inside their parent and are loaded on demand, not as separate top-level skills.

---

## Manual methods

Use these to install a single skill by hand, or into a harness other than Claude Code (other harnesses use their own skill directory, but the copy step is the same). Newer skills are nested under a category folder; copy the skill's leaf folder, the one that contains `SKILL.md`, regardless of how deep it sits.

---

## Method 1 — Global install

Available in every Claude Code project on your machine.

```bash
cp -r skills/starting-project-session ~/.claude/skills/starting-project-session
```

Invoke it in any Claude Code session:

```
/starting-project-session
```

Repeat for any other skill you want globally available.

---

## Method 2 — Project-level install

Scoped to a single project. Useful when a skill is specific to one repo or when teammates need it available after cloning.

```bash
mkdir -p .claude/skills
cp -r /path/to/agent-skills/skills/starting-project-session .claude/skills/
```

---

## Method 3 — Auto-invoke on session start

Automatically load a skill every time Claude Code opens in a project. Add a reference line to the project's `CLAUDE.md`:

```md
## Skills
Load and follow ~/.claude/skills/starting-project-session/SKILL.md at the start of every session.
```

Claude Code reads `CLAUDE.md` on startup and follows the skill's workflow without you having to invoke it manually. This is the right method for skills like `starting-project-session` that you want running every time, not just when you remember to call them.

---

## Verify the install

After installing, open a Claude Code session and type the skill name with a leading slash:

```
/starting-project-session
```

If Claude Code does not recognize it, confirm the skill folder is in the correct location and contains a `SKILL.md` file at its root.

---

## Secrets and API keys

Skills that call external APIs read their key from an environment variable and never store it. All keys live in one file outside this repo:

```
~/.config/agent-skills/.env   (chmod 600)
```

Each skill documents the exact variable name it expects. The current contract is listed in [`.env.example`](.env.example); copy a key's line into your real env file and fill in the value. Never commit a real key, and never paste one into a `SKILL.md`.

The repo is public, so the real env file is deliberately kept outside the repo tree where an accidental commit cannot reach it. As the project grows or moves to more than one machine, this same environment-variable contract can be fed by a secrets manager such as 1Password CLI or Doppler that injects the variables at runtime, without changing any skill.
