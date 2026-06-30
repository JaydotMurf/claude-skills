# Testing & Quality

Skills that make agent-built things trustworthy, and make the next agent session smarter than the last one.

## Skills

- [testing-runbook-creator](testing-runbook-creator/SKILL.md) — whenever you test, verify, smoke-test, QA, or debug anything in a repo, capture what you learned as a repo-local entry in `docs/testing-runbook.md`: how to test it, safe vs. destructive actions, setup/seed requirements, cleanup, and exact verification commands with expected output. Read the runbook before testing, follow the existing recipe, and fix it in the same session when reality differs.
- [page-testing-memory](page-testing-memory/SKILL.md) — the general web-page QA process held globally (states, forms across valid/invalid/edge input, auth boundaries from the wrong side, responsive breakpoints, screenshot evidence), while every page-specific fact — selectors, routes, test accounts, seed data, cleanup quirks — stays in the repo's testing runbook. Composes testing-runbook-creator.
- [browser-qa](browser-qa/SKILL.md) — drive a real Chrome through the `chrome-devtools-mcp` server to verify web changes: screenshots at desktop/tablet/mobile for layout, a performance trace with Core Web Vitals (LCP/INP/CLS) against thresholds for perf changes, and console-error/failed-request checks for new features. Every finding ships with its evidence. Composes testing-runbook-creator.

## How they compose

testing-runbook-creator is the foundation. It owns the repo-local memory file (`docs/testing-runbook.md`) and the entry format. Both page-testing-memory and browser-qa keep the general process in the skill and route every page-specific fact they learn into that runbook, so the process travels across projects while the specifics stay where they are true.

The build prompts that generated each skill live under [meta-prompts/testing-and-quality/](../../meta-prompts/testing-and-quality/).

## Reconciled skills

Relocated here from the flat library in the taxonomy reconciliation (Pass 1). Source is noted per skill; vendored skills are kept close to upstream and carry `source:` in their frontmatter.

- [tdd](tdd/SKILL.md) — test-driven development: red-green-refactor, integration tests written before implementation. (mattpocock)
- [diagnosing-bugs](diagnosing-bugs/SKILL.md) — a diagnosis loop for hard bugs and performance regressions. (mattpocock)
- [python-script-checker](python-script-checker/SKILL.md) — audit Python scripts against documented standards and emit a compliance report. (original; status: coming-soon)
