# Contributing

Skills in this repo must be usable by a DoD contractor or veteran without modification. If it requires classified access, org-specific tooling, or internal URLs, it does not belong here.

---

## How to submit a skill

1. Fork this repo.
2. Pick the category your skill belongs to and create a folder under it using lowercase and hyphens: `skills/<category>/your-skill-name/`.
3. Add a `SKILL.md` file using the template in [`templates/SKILL-TEMPLATE.md`](templates/SKILL-TEMPLATE.md).
4. Open a pull request with a one-paragraph description of what the skill does and who benefits from it.

To submit a runbook instead, create `runbooks/your-runbook-name/RUNBOOK.md` from [`templates/RUNBOOK-TEMPLATE.md`](templates/RUNBOOK-TEMPLATE.md). A runbook may only name skills that already exist in the library.

---

## Required structure

Every skill must include:

- Frontmatter at the top: `name`, `description`, `tags`, `audience`
- A trigger description: the exact conditions that should cause an agent to invoke this skill, and when it should not
- Numbered steps the agent follows in order
- At least one guardrail: a hard constraint the agent must never violate while the skill is active
- An output contract: what the skill produces and in what shape
- A verification standard: the evidence that must exist before the skill calls itself done

See [`templates/SKILL-TEMPLATE.md`](templates/SKILL-TEMPLATE.md) for the full template with inline comments explaining each section.

---

## What makes a skill acceptable

- It works without modification for a typical GovTech contractor or veteran.
- It contains no classified content, no org-specific tooling, and no internal URLs.
- The trigger is specific enough that an agent knows exactly when to invoke it.
- The steps are numbered and produce a predictable, consistent output.
- It has at least one guardrail and a stated verification standard.

Skills that are too vague, too narrow, or require internal access will be closed without merge.

---

## Continuous integration

Quality is enforced in three tiers. The first tier is the merge gate and runs on
every push and pull request; the other two run on demand.

### Tier 1 — deterministic gate (runs in CI)

Two scripts, both free and offline. Run them locally before opening a PR:

```bash
bash scripts/check.sh   # static conformance
bash scripts/test.sh    # offline behavioral tests
```

`check.sh` checks shell, Python, and JSON syntax across the repo; confirms native
skills carry all six authoring elements and that their Output contract and
Verification sections are non-empty; confirms vendored skills declare a `source:`;
confirms every runbook reference resolves and that each runbook composes at least
two skills; confirms `scripts/skills-index.json` is current; and lints native
procedures for inline bold and AI-isms. Vendored skills (those marked
`standard: upstream-vendored`) are exempt from the authoring and writing-rule
gates but still syntax-checked.

`test.sh` runs the Python selftests and drives each script-bearing skill through
its no-key failure and argument-validation paths in a scrubbed environment, plus
the HTML offline-safety check. No keys, no network, no spend.

If you add or move a skill, regenerate the manifest so the freshness check stays
green:

```bash
bash scripts/gen-index.sh --write
```

### Tier 2 — behavioral evals (on demand)

`tests/evals/` scores skills and runbooks against rubrics drawn from their own
Verification standards. `tests/evals/run.sh --validate` is free and offline; the
judged run spends tokens and is intentionally kept off the merge gate. See
`tests/evals/README.md`.

### Tier 3 — verification ledger

`docs/verification-ledger.md` records dated evidence from real paid or
hardware-dependent runs. Update a skill's row when you validate it live.
