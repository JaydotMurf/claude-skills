---
name: heavy-file-ingestion
description: Convert heavy files (large PDFs, slide decks, spreadsheets, CSV dumps, long docs) into lightweight Markdown and CSV artifacts plus an index before any analysis, and analyze the artifacts rather than the original. Use whenever the user shares a heavy or binary document, or asks for analysis that touches one. Other skills that must read a heavy file ingest it through this first.
tags: [ingestion, documents, conversion, core-infrastructure]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Heavy File Ingestion

Large binary documents are expensive and unreliable to read directly. This skill converts them into small Markdown and CSV artifacts first, writes an index, and from then on all analysis reads the artifacts. The original heavy file is never analyzed directly.

## When to use this skill

Invoke it when:

- The user shares a heavy or binary document: a big PDF, a slide deck, a spreadsheet, a CSV dump, or a long doc.
- The user asks a question or analysis that depends on such a file.
- Another skill needs the contents of a heavy file before it can act.

Do not invoke it for files that are already small plain text or Markdown and comfortably readable as-is.

## Saved defaults

- Output: an `_ingested/` folder next to each source (override with `--out`).
- Chunk threshold: 1200 lines per artifact (override with `--max-lines`).
- No API key required.

## Steps

### Step 1 — Convert before reading

Run the script on the heavy file or files. Do not open or analyze the original first; conversion comes before any reading.

```bash
./ingest.sh path/to/file.pdf path/to/data.csv [--max-lines 1200] [--out DIR]
```

### Step 2 — Install a converter if one is missing

CSV and plain-text sources need no external tools. PDF, Word, PowerPoint, Excel, and HTML need `markitdown`. If the script reports it is missing, install it and re-run:

```bash
pip install 'markitdown[all]'
```

The script names the exact install command for whatever a given file needs. Completion: every source produced an artifact, or the index records why it could not.

### Step 3 — Read the index, then the artifacts

Open `_ingested/INDEX.md` to see every artifact and its one-line summary. For very large sources, read the numbered `*.chunkNN.md` files in order rather than the whole artifact at once.

### Step 4 — Analyze artifacts only

Answer the user's request from the converted artifacts. Never reach back to the original heavy file for analysis.

## Conversion recipes

| Source type | Artifact | Tool |
|---|---|---|
| PDF, DOCX, PPTX, XLSX, HTML, EPUB | `<name>.md` | `markitdown` (install: `pip install 'markitdown[all]'`) |
| CSV | `<name>.csv` plus `<name>.summary.md` (header, column count, row count, sample) | built-in, no tool |
| TXT, MD, LOG | `<name>.md` | built-in, no tool |

If a converter is absent, the script records the gap in the index with the install command rather than failing silently. When a tool is present that you prefer over markitdown for a type (for example `pdftotext` or `pandoc`), it can be substituted in the recipe.

## Chunking

Any artifact longer than the line threshold (default 1200) is split into `<name>.chunkNN.md` files, each at most that many lines, so every readable unit stays a comfortable size. The full artifact is kept alongside the chunks, and the index records the chunk count. Read large sources chunk by chunk.

## For other skills

If your skill needs the contents of a heavy file, ingest it through this skill and read from `_ingested/`. Do not parse a PDF or spreadsheet inline in another skill. One ingestion path keeps artifacts small, consistent, and indexed.

## Guardrails

- Never analyze, summarize, or answer from the original heavy file; convert it first and read the artifacts.
- Never claim a heavy file was processed unless its artifact exists in `_ingested/` and is recorded in the index.
- Never install tools silently as a side effect of analysis; report the missing converter and its install command.

## Output contract

An `_ingested/` folder beside each source containing: the converted artifact (`.md`, or `.csv` plus `.summary.md`), any `*.chunkNN.md` chunk files for large sources, and an `INDEX.md` table with one row per source listing type, artifact, size, chunk count, and a one-line summary.

## Verification standard

Do not call the task done until: every requested source has an artifact in `_ingested/` (or an index row stating why it could not be converted), `INDEX.md` exists with a row per source, and any source over the chunk threshold produced numbered chunk files. The CSV and text paths run with no external tools; the PDF and office paths require markitdown and are confirmed once it is installed.
