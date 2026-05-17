# Installation

Three ways to use claude-skills. Choose the method that matches how you work.

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
cp -r /path/to/claude-skills/skills/starting-project-session .claude/skills/
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
