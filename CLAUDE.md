# claude-skills

Public library of reusable Claude Code skills for veterans and GovTech professionals. Every file in this repo is either a skill, a template, or documentation for how to use and contribute skills.

---

## Writing rules

- No bold formatting inside prose.
- No bullet points longer than one sentence.
- No rhetorical openers ("In today's fast-paced world...").
- No AI-isms: leverage, utilize, seamlessly, robust, cutting-edge.
- Write the way a senior engineer writes documentation: precise, direct, human.

---

## Skill authoring standard

Every skill in this repo must have:

1. Frontmatter at the top: `name`, `description`, `tags`, `audience`
2. A trigger description: the exact conditions under which Claude should invoke this skill
3. Numbered steps Claude follows in order
4. At least one guardrail: a hard constraint Claude must never violate while the skill is active

Skills without all four are not merge-ready.

---

## File naming convention

All lowercase, hyphens, no spaces. No camelCase, no underscores.

Correct: `starting-project-session/SKILL.md`
Incorrect: `StartingProjectSession/skill.md`, `starting_project_session/SKILL.md`
