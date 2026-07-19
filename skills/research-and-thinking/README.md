# Research & Thinking

Skills that turn raw inputs, such as voice notes, meetings, document piles, and weekly noise, into structured, reviewable thinking.

Expected: 7 skills. All 7 are built.

## Skills

- [brain-dump-processor](brain-dump-processor/SKILL.md) — process messy multi-topic input (voice transcripts, brain dumps, rambling notes) into cleanly separated, individually evaluated ideas, each with context, an honest assessment, and a next step, filed as dated notes.
- [intention-clarifier](intention-clarifier/SKILL.md) — turn a single vague intention or nagging thought into a stated goal, via reflection-back and a targeted question bank, ending on one concrete 24-hour first step and a routed next move.
- [meeting-prep](meeting-prep/SKILL.md) — prepare for a meeting before it happens: refresh context on the attendees, set explicit goals, draft the goal-linked questions, and name the likely landmines. The pre-meeting counterpart to meeting-synthesis.
- [meeting-synthesis](meeting-synthesis/SKILL.md) — turn a meeting transcript or recording into a per-topic synthesis: takeaways, decisions with their decider, action items with owner and deadline, open questions, and durable context, keeping what was said separate from what was inferred.
- [weekly-signal-diff](weekly-signal-diff/SKILL.md) — compare a defined set of inputs against a maintained state file and report only meaningful changes, ordered by importance, with at most three follow-ups and an honest short answer for a quiet week.
- [assumption-checker](assumption-checker/SKILL.md) — adversarially audit a plan, argument, or strategy document for unstated assumptions, missing evidence, contradictions, and world-model gaps, leading with the single most dangerous assumption and closing with the three highest-leverage questions.
- [reading-pack-builder](reading-pack-builder/SKILL.md) — build one self-contained offline HTML reading pack from a set of local documents, with a reasoned reading order, one-at-a-time navigation, and a locally saved read/unread marker.

Skills are generated one at a time from the build prompts under `meta-prompts/research-and-thinking/`. Each lands in its own folder here as `research-and-thinking/<skill-name>/SKILL.md`.

## Reconciled skills

Relocated here from the flat library in the taxonomy reconciliation (Pass 1). All four are vendored from mattpocock/skills and carry `source:` in their frontmatter.

- [grilling](grilling/SKILL.md) — interview the user relentlessly to stress-test a plan or design before building. (mattpocock)
- [grill-me](grill-me/SKILL.md) — a relentless interview to sharpen a plan or idea with no codebase context. (mattpocock)
- [grill-with-docs](grill-with-docs/SKILL.md) — a codebase-aware grilling that captures decisions as ADRs and glossary entries as it goes. (mattpocock)
- [teach](teach/SKILL.md) — teach the user a new skill or concept within the workspace across multiple sessions. (mattpocock)
