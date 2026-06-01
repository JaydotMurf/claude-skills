# Prompt Builder — Examples

## Example 1 — Meeting notes to structured prompt

**Input (raw notes from the user):**

```
I keep summarizing meeting notes from client calls. The notes are messy —
action items buried in paragraphs, decisions mixed with small talk. I want
a prompt that pulls out the key stuff. Output should be short. Bullets.
Three sections: decisions, action items, open questions. I don't want Claude
to add anything that wasn't in the notes.
```

**Output (structured prompt):**

```
## Role
You are a meeting note analyst. Your job is to extract structured information
from raw meeting notes without adding interpretation or content that was not
explicitly stated.

## Instructions
1. Read the meeting notes provided by the user.
2. Identify and extract: decisions made, action items assigned, and open
   questions left unresolved.
3. If an item is ambiguous, place it under "Open questions" rather than
   guessing its category.
4. Do not include small talk, pleasantries, or any content that is not a
   decision, action item, or open question.

## Output format
Three sections, each using a bulleted list. Section headers: Decisions,
Action items, Open questions. Each bullet is one sentence. If a section has
no items, write "None."

## Guardrails
- Never add context, interpretation, or content not present in the notes.
- Never combine two distinct items into a single bullet.
- Never omit a section, even if it is empty.
```
