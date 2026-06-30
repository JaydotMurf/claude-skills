---
name: research-engine
description: Answer a real research question from messy inputs with a chain of custody — heavy sources converted to clean artifacts first, gaps filled with current information, conclusions stress-tested adversarially, and the result packaged for human review.
tags: [research, ingestion, synthesis, publishing]
audience: analysts, GovTech professionals, solo operators
---

# The Research Engine

For real research questions with messy inputs: a folder of PDFs, some meeting recordings, and a claim you are not sure you believe. The ordering is the trick — convert the heavy sources to clean text first, then everything downstream is faster, cheaper, and reusable.

## Outcome

A research artifact whose every claim traces back to a converted source and whose conclusions have been stress-tested by a separate skeptical pass, delivered as a styled HTML artifact and, when it needs human review, presented in a reasoned reading order.

## Skills it calls

1. `core-infrastructure/heavy-file-ingestion` — takes the folder of heavy sources (PDFs, recordings, spreadsheets); produces an `_ingested/` folder with converted `.md` artifacts and an `INDEX.md`. Hands the clean converted artifacts to the next steps.
2. `core-infrastructure/current-info-search` — takes the open questions left by the sources; produces answers grounded in live search with dated Sources entries. Hands the current facts into the emerging analysis.
3. `research-and-thinking/assumption-checker` — takes the emerging conclusions; runs adversarially against them, opening with the single most dangerous assumption and closing with the three questions that most reduce risk. Hands the surviving, caveated conclusions forward.
4. `research-and-thinking/meeting-synthesis` — takes any ingested meeting recordings; produces a topic-organized synthesis with decisions, action items, and durable context. Hands the synthesized findings into the artifact.
5. `core-infrastructure/html-artifacts` — takes the stress-tested findings and synthesis; produces a self-contained `YYYY-MM-DD-<slug>.html`. Hands the artifact path to the next step.
6. `research-and-thinking/reading-pack-builder` — takes the artifact plus its supporting sources; produces a single `.html` reading pack with a reasoned reading order, one-at-a-time navigation, and read/unread state for human review.

## Verification

- `_ingested/INDEX.md` lists every source with its converted artifact; no analysis ran against an unconverted heavy source.
- Every current-information claim carries a Sources entry with a URL and a date.
- The assumption-checker pass exists as a distinct artifact, not the same conversation grading itself, and names the most dangerous assumption plus three questions.
- The final artifact passes the self-contained check, and the reading pack states its document count and reading order.
