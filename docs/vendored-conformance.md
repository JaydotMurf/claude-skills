# Vendored skill conformance

This repo's authoring standard requires six elements in every native skill: frontmatter, a trigger description, numbered steps, a "Never..." guardrail, an output contract, and a verification standard.

12 skills remain vendored — imported from external libraries and kept close to upstream rather than rewritten, so they can still be updated from source. They carry `source:` and `standard: upstream-vendored` in their frontmatter and are not held to the six-element standard while vendored. This file tracks the gap so a later native adoption knows exactly what each skill needs, and so the gap is honest rather than hidden. (Seven skills have been adopted natively so far — `codebase-design`, `visual-plan`, `visual-recap`, and the `grilling` / `grill-me` / `grill-with-docs` / `teach` research skills — each now carries all six elements and its row was removed.)

Policy: do not edit vendored content to close these gaps. When a vendored skill is adopted natively, drop its `standard: upstream-vendored` marker, bring it to the six-element standard, and remove its row here.

## Status

All 12 vendored skills already have the first four elements: frontmatter, a trigger description, numbered steps, and a "Never..." guardrail. The gaps are in the last two elements — an explicit Output contract section and an explicit Verification standard section.

| Skill | Source | Output contract | Verification standard |
|---|---|---|---|
| software-engineering/improve-codebase-architecture | mattpocock | missing | missing |
| software-engineering/domain-modeling | mattpocock | missing | missing |
| software-engineering/prototype | mattpocock | missing | missing |
| software-engineering/setup-skills | mattpocock | missing | missing |
| software-engineering/to-issues | mattpocock | missing | missing |
| software-engineering/to-prd | mattpocock | missing | missing |
| software-engineering/triage | mattpocock | missing | missing |
| testing-and-quality/tdd | mattpocock | missing | missing |
| testing-and-quality/diagnosing-bugs | mattpocock | missing | missing |
| agent-operations/ask-workflow | mattpocock | missing | missing |
| agent-operations/handoff | mattpocock | missing | missing |
| agent-operations/writing-great-skills | mattpocock | missing | missing |

"Missing" means the skill has no section formally labeled as that element under the six-element standard; several describe their output or success criteria inline in prose. The point of native adoption is to make those explicit and verifiable, not to assume they produce nothing today.
