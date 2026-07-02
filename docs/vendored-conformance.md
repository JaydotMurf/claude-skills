# Vendored skill conformance

This repo's authoring standard requires six elements in every native skill: frontmatter, a trigger description, numbered steps, a "Never..." guardrail, an output contract, and a verification standard.

19 skills were originally imported from external libraries and vendored — kept close to upstream rather than rewritten, marked `standard: upstream-vendored`, and exempt from the six-element standard while vendored. This file tracked the per-skill gap so a later native adoption knew exactly what each needed.

## Status

All 19 have now been adopted natively. Each carries all six elements, the `standard: upstream-vendored` marker has been dropped (the `source:` provenance is kept), and there are no vendored skills remaining. The `check.sh` gate now holds every skill in the library to the full authoring and writing-rule standard.

The adoption ran in batches: `codebase-design` (PR #22); `visual-plan` and `visual-recap`, which also had their inline bold stripped to clear the writing-rule gate (PR #23); the four `research-and-thinking` interview and teaching skills — `grilling`, `grill-me`, `grill-with-docs`, `teach` (PR #26); `testing-and-quality/tdd` and `diagnosing-bugs` (PR #27); the three `agent-operations` skills — `ask-workflow`, `handoff`, `writing-great-skills` (PR #28); and the seven `software-engineering` skills — `improve-codebase-architecture`, `domain-modeling`, `prototype`, `setup-skills`, `to-issues`, `to-prd`, `triage`.

## Policy for future imports

The vendoring convention stays available for anything imported later. A newly imported skill can carry `source:` and `standard: upstream-vendored` to sit outside the six-element gate until it is adopted natively; when it is, drop the marker, bring it to the standard, and record the adoption here. Do not edit vendored content to close gaps before adopting it natively.
