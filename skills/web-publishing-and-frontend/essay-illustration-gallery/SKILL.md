---
name: essay-illustration-gallery
description: Turn a finished essay into a consistent illustration gallery — select the moments across the full arc, lock one style, generate the frames, caption each with why it was chosen, and assemble a single self-contained gallery page. Composes image-gateway for generation and site-publisher for publishing if asked. Use when the user shares an essay and asks for illustrations, images, or a gallery.
tags: [illustration, gallery, essay, images, web-publishing-and-frontend]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Essay Illustration Gallery

Takes a finished essay and produces a consistent illustration gallery: moments chosen across the full arc, one locked style so every frame matches, a caption per frame explaining the choice, and a single self-contained gallery page. Generation runs through image-gateway; publishing, only if asked, runs through site-publisher. Assembly follows the html-artifacts convention of one self-contained file.

## When to use this skill

Invoke it when the user shares an essay (or points at one) and asks for illustrations, images, or a gallery for it. The essay must be finished; this skill illustrates existing text, it does not write or edit it.

Do not invoke it for a single standalone image (use image-gateway), for illustrating something that is not an essay or article, or before the essay text exists. Do not publish the gallery unless the user asks for it to go live.

## Interview before building

Two inputs shape every gallery; ask once if the user has not said:

- Style direction — the look to lock (hand-drawn editorial cartoon, photoreal, watercolor, etc.). Help the user turn it into a precise style descriptor: medium, linework, palette, texture, negative space, and a no-text-in-image rule.
- Frame count — how many frames a typical essay gets. For the first pass on any new essay, use a reduced count of 5–6 and review before scaling up.

Recorded assumption (build time): no style or frame count was supplied, so the skill ships an example spec using a hand-drawn ink-and-wash editorial cartoon descriptor and a reduced 5-frame count. Replace both with the user's real preferences on first use.

## The spec

One JSON file drives generation and assembly. See `example-spec.json`:

- `essay`, `description`, optional `essay_path`.
- `style_descriptor` — the single locked style string, prepended to every frame prompt.
- `output` — path for the assembled gallery HTML.
- `frames[]` — each with `id`, `passage` (the exact passage it illustrates), `rationale` (one line on why this moment), `caption` (reader-facing), and `prompt` (the scene to draw).

## Steps

### Step 1 — Read the essay and map its arc

Read the full essay and identify its arc: opening, turns, midpoint, climax, resolution. Completion: you can name the beats of the piece.

### Step 2 — Select moments across the full arc

Choose frames spread across the whole arc, not clustered at the start. Tie each to a specific passage and write a one-line rationale for why that moment earns a frame. Completion: a frame list where every frame names a passage and a rationale, and the selection spans beginning to end.

### Step 3 — Lock one style descriptor

Write or confirm the single detailed style descriptor and record it in the spec's `style_descriptor`. It is prepended to every frame prompt so all frames match. Do not vary the style between frames. Completion: one style descriptor is locked in the spec.

### Step 4 — Write per-frame prompts and captions

For each frame, write the scene `prompt` (the style descriptor is added automatically) and a reader-facing `caption` explaining why that moment was chosen. Completion: every frame has a prompt and a caption.

### Step 5 — Generate the frames

Run generation through image-gateway:

```bash
./build-gallery.sh generate SPEC
```

Each frame is generated as `style_descriptor. prompt`. Existing frames are skipped, so regenerating one frame does not redo the others. Never call an image API directly. Completion: every frame has an image.

### Step 6 — Assemble the gallery page

Build the single self-contained page:

```bash
./build-gallery.sh assemble SPEC
```

Images are embedded as base64 so the gallery is one portable HTML file, per the html-artifacts convention. Open it and confirm every frame renders with its passage and caption. Completion: the gallery opens and renders fully offline.

### Step 7 — Write the social note

Write a short, ready-to-paste social note announcing the gallery. If a voice skill exists, write it in the user's voice; otherwise keep it plain and let the user adjust. Completion: a short social note is ready to paste.

### Step 8 — Publish only if asked

If, and only if, the user asks for the gallery to go live, hand the gallery page to site-publisher. Completion: site-publisher returns a live URL.

## Guardrails

- Never call an image API directly or write your own deploy steps; route generation through image-gateway and publishing through site-publisher.
- Never vary the style between frames; one locked descriptor is prepended to every prompt.
- Never cluster frames at the start of the essay; the selection must span the full arc, each frame tied to a specific passage.
- Never publish the gallery unless the user explicitly asks for it to go live.

## Output contract

A single self-contained gallery HTML file at the spec's `output`, embedding every frame as base64 with its passage and caption and the locked style noted, plus the per-frame source images under `<output-dir>/<slug>-frames/` and a short ready-to-paste social note. Optionally, a live URL from site-publisher.

## Verification standard

Do not call the task done until: frames span the full arc with each tied to a passage and rationale, one style descriptor was locked and used for every frame, the assembled page opens and renders every frame with its caption fully offline, and a social note exists. Build-time test: assembly was verified end to end with stub frames on a reduced 5-frame spec — `build-gallery.sh assemble` produced a self-contained single-file gallery with all five frames, passages, and captions rendering, confirmed by screenshot. The live generation pass requires an API key and is run on first real use; `build-gallery.sh generate` was confirmed to fail cleanly when the key is absent.
