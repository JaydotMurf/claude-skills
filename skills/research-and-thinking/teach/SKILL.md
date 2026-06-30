---
name: teach
description: Teach the user a new skill or concept, within this workspace, over multiple sessions. Use when the user explicitly runs /teach or says "I want to learn about X" in the current directory.
tags: [productivity, learning, education]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
source: mattpocock
standard: upstream-vendored
---

# Teach

A stateful multi-session teaching workspace. The user intends to learn the topic over multiple sessions.

Treat the current directory as the teaching workspace. All state lives here.

## Workspace structure

- `MISSION.md` — why the user is interested in the topic. Use the format in [references/MISSION-FORMAT.md](references/MISSION-FORMAT.md).
- `./reference/*.html` — compressed learnings from lessons: cheat sheets, reference algorithms, syntax, glossaries. Designed for quick reference and good printing.
- `RESOURCES.md` — high-quality resources that ground your teaching. Use the format in [references/RESOURCES-FORMAT.md](references/RESOURCES-FORMAT.md).
- `./learning-records/*.md` — what the user has learned, titled `0001-<dash-case-name>.md` (number increments). Use the format in [references/LEARNING-RECORD-FORMAT.md](references/LEARNING-RECORD-FORMAT.md).
- `./lessons/*.html` — one self-contained HTML lesson per file, titled `0001-<dash-case-name>.html`.
- `./assets/*` — reusable components (stylesheets, quiz widgets, simulators) shared across lessons.
- `NOTES.md` — user preferences and working notes.

## Steps

### Step 1 — Establish the mission

Every lesson must be tied to the mission — the reason the user is interested in the topic.

If the user is unclear about their mission, or `MISSION.md` is not populated, your first job is to question the user on why they want to learn this. Failing to understand the mission makes lessons feel too abstract and gives you no way to judge what to teach next.

Missions may change as the user develops skills. Update `MISSION.md` when they do, and add a learning record to capture the change.

### Step 2 — Find or update resources

Before the `RESOURCES.md` is well-populated, find high-quality resources that will help the user acquire knowledge. Never trust parametric knowledge alone — find sources.

For skill-heavy topics, prioritise high-quality practical resources. For knowledge-heavy topics, prioritise authoritative references.

### Step 3 — Determine the zone of proximal development

If the user specifies exactly what they want to learn, teach that. Otherwise, determine their zone of proximal development by reading their `./learning-records/` and figuring out the next right thing based on their mission.

Each lesson should challenge the user just enough — not so easy it's boring, not so hard it overwhelms.

### Step 4 — Produce the lesson

A lesson is one self-contained HTML file saved to `./lessons/`. Each lesson:
- Teaches one tightly scoped thing tied to the mission.
- Is short and completable quickly.
- Is beautiful — clean, readable typography. Think Tufte.
- Links via HTML anchors to other lessons and reference documents.
- Recommends a primary source for the user to read or watch.
- Contains a reminder to ask follow-up questions.

Before writing a lesson, read `./assets/` and build from existing components. When a lesson needs something new and reusable, write it as a component in `./assets/` rather than inlining it.

A shared stylesheet is the first component every workspace earns. Every lesson links it.

Open the lesson file for the user by running a CLI command after writing it.

### Step 5 — Also produce a reference document

While creating lessons, also create corresponding reference documents in `./reference/*.html`. These are the compressed essence of the lesson — useful for quick recall, not the first time through. Lessons will rarely be revisited; reference documents will be.

### Step 6 — Write a learning record

After significant lessons or insight moments, write a learning record. These capture non-obvious lessons and key insights the user may need to revise later. They are used to calculate zone of proximal development in future sessions.

## Guardrails

- Never trust parametric knowledge when teaching — always reference RESOURCES.md and find sources.
- Never design a lesson that skips the mission grounding.
- Never inline code or styling that a second lesson would need to duplicate — write it as a shared asset instead.
- Never ask for wisdom-level questions — delegate those to a community.
