---
name: reading-pack-builder
description: Given a set of local documents to review, build one self-contained local HTML reading pack that presents them one at a time in a deliberate order, with an index page carrying one-line summaries and reading-order reasoning, previous/next navigation, and a read/unread marker saved locally. Everything works offline. Use when the user has a pile of documents to review or asks for a "reading pack".
tags: [research-and-thinking, reading, html, offline]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Reading Pack Builder

A folder of documents to review has no shape: no order, no progress, no sense of what to read first or what is left. This skill turns that pile into one self-contained HTML file that presents the documents one at a time in a deliberate order, explains why that order, and remembers what has been read — all offline, no server, no network.

## When to use this skill

Invoke it when:

- The user points at several local documents and wants to review them in order.
- The user asks for a "reading pack", a "review packet", or "put these in an order for me".

Do not invoke it for a single document (just open it), for documents that need editing rather than reading, or when the user wants the content summarized rather than presented for reading. This skill arranges reading; it does not replace it.

## Saved defaults

These are the assumed interview answers, recorded here because the build ran without a live interview. Change them in place if they are wrong.

- Save location: `~/Documents/reading-packs/`, one file per pack named `YYYY-MM-DD-<slug>.html`.
- Visual style: inherited from the html-artifacts skill. The shipped `template.html` already carries those house-style tokens (light default, automatic dark via `prefers-color-scheme`), so the pack matches every other artifact in this library without a separate style decision.

## Steps

### Step 1 — Gather the source documents

Confirm the exact list of local documents to include and that each one is readable. Note the format of each (Markdown, plain text, HTML, PDF). Completion: you have the full ordered set of source paths.

### Step 2 — Decide the reading order

Choose a deliberate order: foundational or context-setting documents first, then what builds on them, then the detail. The order is a judgment, not the order the files happened to be listed in. Write a one-line reason for each document's position.

### Step 3 — Convert each document to clean HTML

Convert each source to clean, structural HTML — headings, paragraphs, lists, tables preserved — stripped of editor cruft. Keep the structure of the original; do not summarize or rewrite the content. This is the reading pack, so the documents must be present in full.

### Step 4 — Build the pack from the template

Copy `template.html` from this skill folder to `~/Documents/reading-packs/YYYY-MM-DD-<slug>.html`. Set the `PACK` config (id, title, and one entry per document in reading order, each with title, one-line summary, and the reason from Step 2). Replace the demo `<article class="doc">` blocks with the converted documents from Step 3, one article per document, `data-doc-id` matching the `PACK` ids in the same order. Keep all CSS and JS inline; add nothing external.

### Step 5 — Verify self-containment and open it

Confirm the file pulls no external resource, then open it:

```bash
grep -nEi 'src=|href=["'"'"']?https?:|@import|<link[^>]+stylesheet|<script[^>]+src=' PACK.html && echo "external ref found" || echo "self-contained"
open PACK.html   # macOS; use xdg-open on Linux
```

Click into a document, use previous/next, mark one read, return to the index, and confirm the read badge persists after a reload. Completion: the grep finds no external reference and you have seen the index, the one-at-a-time navigation, and the read marker work.

## Guardrails

- Never reference an external resource needed to render: no remote scripts, stylesheets, fonts, or images. The pack must work fully offline as a local file.
- Never split the pack across multiple files; it is one self-contained HTML file holding every document.
- Never summarize or truncate a source document in place of its full content; the pack is for reading the documents, not abstracts of them.
- Never declare it done without opening it and confirming navigation and the persistent read marker actually work.

## Output contract

One self-contained `.html` file at `~/Documents/reading-packs/YYYY-MM-DD-<slug>.html` containing every source document as clean HTML, an index with one-line summaries and a reasoned reading order, previous/next one-at-a-time navigation, and a read/unread marker persisted in `localStorage`. The chat reply states the pack path and the document count.

## Verification standard

Do not call the task done until: the self-containment grep finds no external reference, the pack opens offline, the index shows every document with its summary and order reasoning, previous/next moves through the documents one at a time, and a marked-read document keeps its badge across a reload. The shipped `template.html` is a worked, self-contained example (two demo documents) that passes the grep. Build-time note: no target documents were supplied at build time, so the three-document acceptance test runs at first real invocation against the documents the user points to.
