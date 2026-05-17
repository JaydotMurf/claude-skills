---
# Required. The skill name — matches the folder name and the slash command used to invoke it.
name: your-skill-name

# Required. One sentence: what does this skill do and what triggers it?
# This is what Claude reads to decide whether to invoke the skill automatically.
description: Description of what this skill does and what triggers it.

# Optional. Comma-separated list of relevant tags for discoverability.
tags: [productivity, prompting, session-management]

# Required. Who is the primary audience for this skill?
audience: DoD contractors, veterans, solo operators

# Optional. Set to "coming-soon" if this skill is a placeholder, not yet complete.
# status: coming-soon
---

# Skill Title

<!-- One or two sentences. What problem does this skill solve? Be specific. -->

## Purpose

<!-- Explain what this skill does and why it exists. Write for someone who knows Claude Code
     but has never seen this skill before. Keep it under five sentences. -->

## When to use this skill

<!-- List the exact conditions or phrases that should trigger this skill.
     Be explicit — vague triggers lead to inconsistent behavior. -->

Examples of when Claude should invoke this skill:

- When the user says "..."
- When the user pastes ...
- When the user explicitly runs `/your-skill-name`

## Steps

<!-- Number every step. Claude follows these in order. Do not combine two actions into one step.
     If a step requires user input or approval before continuing, end it with an explicit stop instruction. -->

### Step 1 — [Action]

<!-- What does Claude do here? What does it output? What does it wait for? -->

### Step 2 — [Action]

<!-- Continue as needed. Each step should have one clear action or output. -->

### Step 3 — [Action]

<!-- If Claude must stop and wait for user approval before proceeding, say so explicitly here. -->

## Guardrails

<!-- At least one guardrail is required.
     Guardrails are hard constraints Claude must never violate while this skill is active.
     Write them as "Never..." statements. -->

- Never [do X] until [condition Y is met].
- Never [do Z] if [condition applies].

## Example

<!-- Optional but strongly recommended. A concrete before/after example is the fastest way
     to communicate what this skill actually produces. -->

**Input:**

```
[What the user provides — raw notes, a message, a paste, etc.]
```

**Output:**

```
[What Claude produces in response — exact format, structure, and content.]
```
