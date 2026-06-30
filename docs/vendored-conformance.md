# Vendored skill conformance

This repo's authoring standard requires six elements in every native skill: frontmatter, a trigger description, numbered steps, a "Never..." guardrail, an output contract, and a verification standard.

19 skills were imported from external libraries and are vendored — kept close to upstream rather than rewritten — so they can still be updated from source. They carry `source:` and `standard: upstream-vendored` in their frontmatter and are not held to the six-element standard while vendored. This file tracks the gap so a later native adoption knows exactly what each skill needs, and so the gap is honest rather than hidden.

Policy: do not edit vendored content to close these gaps. When a vendored skill is adopted natively, drop its `standard: upstream-vendored` marker, bring it to the six-element standard, and remove its row here.

## Status

All 19 vendored skills already have the first four elements: frontmatter, a trigger description, numbered steps, and a "Never..." guardrail. The gaps are in the last two elements — an explicit Output contract section and an explicit Verification standard section.

| Skill | Source | Output contract | Verification standard |
|---|---|---|---|
| software-engineering/codebase-design | mattpocock | missing | present |
| software-engineering/improve-codebase-architecture | mattpocock | missing | missing |
| software-engineering/domain-modeling | mattpocock | missing | missing |
| software-engineering/prototype | mattpocock | missing | missing |
| software-engineering/setup-skills | mattpocock | missing | missing |
| software-engineering/to-issues | mattpocock | missing | missing |
| software-engineering/to-prd | mattpocock | missing | missing |
| software-engineering/triage | mattpocock | missing | missing |
| testing-and-quality/tdd | mattpocock | missing | missing |
| testing-and-quality/diagnosing-bugs | mattpocock | missing | missing |
| research-and-thinking/grilling | mattpocock | missing | missing |
| research-and-thinking/grill-me | mattpocock | missing | missing |
| research-and-thinking/grill-with-docs | mattpocock | missing | missing |
| research-and-thinking/teach | mattpocock | missing | missing |
| agent-operations/ask-workflow | mattpocock | missing | missing |
| agent-operations/handoff | mattpocock | missing | missing |
| agent-operations/writing-great-skills | mattpocock | missing | missing |
| web-publishing-and-frontend/visual-plan | agent-native | missing | present |
| web-publishing-and-frontend/visual-recap | agent-native | missing | present |

"Missing" means the skill has no section formally labeled as that element under the six-element standard; several describe their output or success criteria inline in prose. The point of native adoption is to make those explicit and verifiable, not to assume they produce nothing today.
