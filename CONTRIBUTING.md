# Contributing

Skills in this repo must be usable by a DoD contractor or veteran without modification. If it requires classified access, org-specific tooling, or internal URLs, it does not belong here.

---

## How to submit a skill

1. Fork this repo.
2. Create a folder under `skills/` named after your skill using lowercase and hyphens: `skills/your-skill-name/`.
3. Add a `SKILL.md` file using the template in [`templates/SKILL-TEMPLATE.md`](templates/SKILL-TEMPLATE.md).
4. Open a pull request with a one-paragraph description of what the skill does and who benefits from it.

---

## Required structure

Every skill must include:

- Frontmatter at the top: `name`, `description`, `tags`, `audience`
- A trigger description: the exact conditions or phrases that should cause Claude to invoke this skill
- Numbered steps Claude follows in order
- At least one guardrail: a hard constraint Claude must never violate while the skill is active

See [`templates/SKILL-TEMPLATE.md`](templates/SKILL-TEMPLATE.md) for the full template with inline comments explaining each section.

---

## What makes a skill acceptable

- It works without modification for a typical GovTech contractor or veteran.
- It contains no classified content, no org-specific tooling, and no internal URLs.
- The trigger is specific enough that Claude knows exactly when to invoke it.
- The steps are numbered and produce a predictable, consistent output.
- It has at least one guardrail.

Skills that are too vague, too narrow, or require internal access will be closed without merge.
