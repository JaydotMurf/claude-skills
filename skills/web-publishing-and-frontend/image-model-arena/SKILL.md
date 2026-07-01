---
name: image-model-arena
description: Build and publish image-model comparison pages from a single config — one review page per model plus a shared side-by-side viewer. Composes image-gateway for generation and site-publisher for publishing; never reimplements either. Use to test a new image model, compare models, or add a model to an existing comparison.
tags: [images, comparison, benchmark, web-publishing-and-frontend]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Image Model Arena

Turns one config into an image-model comparison: a per-model review page and a shared side-by-side viewer, with a registry tracking per-image cost and content-policy quirks. Generation runs through image-gateway; publishing runs through site-publisher. This skill composes both and reimplements neither.

## When to use this skill

Invoke it when the user wants to:

- Test a new image model against a standard prompt set.
- Compare two or more image models side by side.
- Add a model to an existing comparison without redoing the others.

Do not invoke it for a single one-off image (use image-gateway directly) or for publishing an arbitrary finished page (use site-publisher directly).

## The config

One JSON file defines the whole arena. See `example-config.json`:

- `arena` — a short id for this comparison.
- `output_dir` — where generated images, built pages, and the registry live.
- `page` — `title` and `description` for the built pages.
- `models[]` — each with `id` (folder-safe), `gateway_model` (the model string image-gateway uses), and `label`.
- `prompts[]` — each with `id`, `category`, and `text`. The standard set covers photorealism, text rendering, diagrams, people, and style range.

Recorded assumption (build time): no prompt set or storage location was supplied, so the skill ships an eight-prompt default set in `example-config.json` (two photorealism/people, two text-rendering, one diagram, two style-range) and defaults `output_dir` under `~/arena/<arena-id>/`. Replace both with the user's real set and path on first use; interview for them if the user has none.

## The pipeline

`arena.sh` runs the pipeline; publishing is a separate site-publisher step.

```bash
./arena.sh all CONFIG [--subset model1,model2] [--only prompt1,prompt2]
```

1. Generate — for each selected (model, prompt), call image-gateway and save to `output_dir/images/<model>/<prompt>.png`. Existing images are skipped, so adding one model only generates that model's missing images.
2. Optimize — copy each image into `output_dir/pages/img/<model>/<prompt>.png`, capped to 1200px wide for the web; originals are kept.
3. Build — write one review page per model (`<model>.html`) and the shared side-by-side viewer (`index.html`, rows = prompts, columns = models).
4. Registry — record per-image cost (parsed from image-gateway's output) and a notes field per model in `output_dir/registry.json`.
5. Publish — hand `output_dir/pages/` to site-publisher to take the viewer and per-model pages live. Never write your own deploy steps here.

## Model selection through image-gateway

`arena.sh` selects each model by exporting `IMAGE_GATEWAY_MODEL=<gateway_model>` before calling image-gateway, matching image-gateway's existing `IMAGE_GATEWAY_*` env convention (`IMAGE_GATEWAY_API_KEY`, `IMAGE_GATEWAY_OUTPUT_DIR`).

Resolved dependency: image-gateway reads `IMAGE_GATEWAY_MODEL` (`MODEL="${IMAGE_GATEWAY_MODEL:-google/gemini-2.5-flash-image}"`), so exporting it before a call selects the model for that run and falls back to the Nano Banana default when unset. Multi-model generation now produces one column per configured `gateway_model`. A live multi-model pass still requires an API key and bills per image.

## Steps

### Step 1 — Confirm intent and config

Confirm the user wants a model test, comparison, or addition. Load or build the config (interview for the prompt set and storage location if absent). Completion: a valid config exists.

### Step 2 — Generate, skipping existing

Run `arena.sh generate CONFIG` (optionally `--subset`/`--only` for a small first pass). Existing images are skipped. Completion: every selected (model, prompt) has an image, with no regeneration of untouched cells.

### Step 3 — Build pages

Run `arena.sh build CONFIG`. Confirm the per-model pages and the shared viewer were written under `output_dir/pages/`. Completion: `index.html` and each `<model>.html` exist and reference optimized images.

### Step 4 — Update the registry

Confirm `registry.json` recorded the per-image cost for each generated image, and add any content-policy quirk observed (a refused prompt, a watermark, a content filter) to that model's `notes`. Completion: the registry reflects this run's costs and quirks.

### Step 5 — Publish through site-publisher

If the user wants it live, hand `output_dir/pages/` to site-publisher. Completion: site-publisher returns a live URL for the viewer.

## Guardrails

- Never call an image API directly or write your own deploy steps; route generation through image-gateway and publishing through site-publisher.
- Never regenerate an image that already exists on disk; adding a model must never redo the others.
- Never run a new model at full scale before a small subset pass (two models, three prompts) has been reviewed.

## Output contract

Under `output_dir`: generated images at `images/<model>/<prompt>.png`, web-optimized copies and built pages under `pages/` (one `<model>.html` per model plus `index.html` side-by-side viewer), and `registry.json` with per-image cost and per-model content-policy notes. Optionally, a live URL from site-publisher.

## Verification standard

Do not call the task done until: every selected cell has an image, the per-model pages and the shared viewer were built and open with images resolving, the registry recorded per-image cost for this run, and (if publishing) the live URL loads. Build-time test: the build pipeline was verified end to end with stub images on a two-model, three-prompt subset — `arena.sh build` produced both per-model pages and the side-by-side viewer with images resolving. Live-validated 2026-07-01: `arena.sh all` on a two-model (`google/gemini-2.5-flash-image`, `google/gemini-3-pro-image`), one-prompt config generated both real images, optimized them, built the per-model pages and side-by-side viewer, and recorded per-image cost to `registry.json` ($0.0387 and $0.1362). Caveat found in the same run: the shipped `example-config.json` lists `black-forest-labs/flux-1.1-pro`, which is not currently an image-output model on OpenRouter and would fail generation — a `gateway_model` must be an OpenRouter model whose `architecture.output_modalities` includes `image`. `arena.sh generate` was also confirmed to fail cleanly when the key is absent.
