---
name: prompt-builder
description: Turns raw notes, examples, and constraints into a structured, reusable prompt organized into four sections — Role, Instructions, Output format, and Guardrails. Invoke when the user wants to engineer a prompt for a repeating task, pastes scattered notes and asks for a clean prompt, or says "help me build a prompt for..." or "write me a prompt that..."
tags: [prompting, productivity, workflow]
audience: DoD contractors, veterans, solo operators building repeatable AI workflows
---

# Prompt Builder

Takes whatever the user gives you — rough notes, examples, a task description, edge cases — and outputs a clean, structured prompt they can reuse across sessions. No prompt engineering background required.

## When to use this skill

- When the user says "help me build a prompt for..." or "write me a prompt that..."
- When the user pastes scattered notes and asks for a clean prompt
- When the user wants to systematize a task they keep doing manually
- When the user wants a reusable prompt they can drop into future Claude Code sessions or share with their team

## Steps

### Step 1 — Gather raw material

If the user has already provided notes, a task description, or examples in their message, skip the ask and go to Step 2. Otherwise, ask for the following — accept whatever they have, do not require all of it:

- What task does this prompt handle?
- Who or what should the assistant act as when running this prompt?
- What are the rules or constraints the assistant must follow?
- What should the output look like — format, length, structure?
- Any examples of good output, or things to avoid?

### Step 2 — Identify the four sections

Before writing, extract these elements from the user's raw material:

| Section | What it captures |
|---|---|
| Role | Who the assistant is when running this prompt |
| Instructions | What the assistant must do, in what order |
| Output format | What the final output looks like — structure, length, formatting |
| Guardrails | What the assistant must never do |

If the user's notes do not cover a section, either infer a reasonable default or flag the gap explicitly. Do not silently skip sections.

### Step 3 — Write the structured prompt

Output the finished prompt in this exact format:

```
## Role
[One or two sentences. Who is the assistant? What is the assistant's job in this prompt?]

## Instructions
[Numbered steps. What must the assistant do, in what order?]

## Output format
[Exact description of the output. Include structure, length constraints, and formatting rules.]

## Guardrails
[Bulleted list. What must the assistant never do? What are the hard limits?]
```

### Step 4 — Confirm and offer refinement

After outputting the prompt, append:

```
This prompt is ready to use. To refine it, tell me:
- Any step that is missing or wrong
- Any guardrail to add or remove
- Any output format changes
```

Stop here. Do not apply changes until the user responds.

## Guardrails

- Never produce a prompt that requires classified information to operate.
- Never skip the Output format section — vague prompts produce vague outputs.
- Never make a prompt longer than the task warrants. A simple task needs a simple prompt.
- Never apply changes from Step 4 until the user explicitly responds.
- Never present multiple prompt variations unprompted — produce one clean version and offer refinement.

## Examples

Reference examples are in [references/examples.md](references/examples.md).
Pull this file when the user asks to see what a finished prompt looks like,
or when an example would help clarify the expected output format.
