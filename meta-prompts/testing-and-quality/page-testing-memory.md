<prompt>
  <task>
    Create a new skill for my AI coding agent called "page-testing-memory", stored
wherever my harness loads skills from. It partners with my testing-runbook-creator
skill.

The skill's job: teach the general page-QA process globally, while keeping all
page-specific knowledge in repo-local runbooks — never in this skill.

The skill must include: (1) trigger conditions — QA or verification of any web page or
UI; (2) the general process: identify the page's states (empty, loaded, error,
loading), test forms with valid/invalid/edge input, verify auth boundaries, check
responsive behavior at standard breakpoints, capture screenshots as evidence; (3) the
knowledge split, stated explicitly: process lives here; selectors, routes, test
accounts, seed data, and cleanup quirks live in the repo's testing runbook; (4) a rule
that when you learn a page-specific fact during QA, it goes into the repo runbook
immediately — and if you find yourself wanting to add a project detail to THIS skill,
that's the signal it belongs in the repo instead.

After writing it, test it by QAing one page in a project I choose, and show me both
the QA findings and what got written to the repo runbook.
</task>
</prompt>
