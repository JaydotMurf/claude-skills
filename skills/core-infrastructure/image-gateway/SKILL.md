---
name: image-gateway
description: Generate or edit images through OpenRouter (Gemini 2.5 Flash Image) with one command and saved defaults. Use when the user asks to create, generate, render, or edit an image, and when another skill needs an image produced. Other skills call this instead of writing their own image API code.
tags: [images, openrouter, core-infrastructure, media]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Image Gateway

The single entry point for image generation and editing. It wraps the OpenRouter image API behind one command with saved defaults, so routine image requests need no per-call setup, and so no other skill has to embed image API code.

## When to use this skill

Invoke it when:

- The user asks to create, generate, render, draw, or make an image.
- The user asks to edit, modify, or restyle an existing image.
- Another skill needs an image produced (a publisher needs a hero image, a media skill needs a thumbnail). That skill calls image-gateway rather than writing its own API call.

Do not invoke it for finding existing images, screenshotting a page, or editing photos that only need a local crop or resize.

## Saved defaults

- Model: `google/gemini-2.5-flash-image` (Nano Banana) by default. Strong at edits, speed, and in-image text. Override per call by exporting `IMAGE_GATEWAY_MODEL=<gateway_model>`, which is how image-model-arena drives multi-model runs through this one gateway.
- Output directory: `~/Pictures/agent-images/`, filenames `YYYY-MM-DD-<slug>.png`. Override per call with `--out`, or globally with `IMAGE_GATEWAY_OUTPUT_DIR`.
- API key: read from `~/.config/agent-skills/.env`. Resolution order is `IMAGE_GATEWAY_API_KEY`, then `OPENROUTER_API_KEY`. The key is never written into this skill or passed on the command line.

## Steps

### Step 1 — Resolve the request

Confirm the prompt text. For an edit, confirm the input image path exists. Note any aspect ratio (`--aspect 16:9`) or output name (`--out name.png`) the user specified. Completion: you have a prompt and, for edits, a readable input path.

### Step 2 — Confirm the key is present

Check that `~/.config/agent-skills/.env` defines `OPENROUTER_API_KEY` or `IMAGE_GATEWAY_API_KEY` with a value. If neither is set, stop and tell the user to add `OPENROUTER_API_KEY` (generate one at openrouter.ai/keys). Do not proceed without a key.

### Step 3 — Run the gateway

Run the script in this skill folder:

```bash
./generate.sh "PROMPT" [--edit INPUT_IMAGE] [--aspect 16:9] [--out NAME.png]
```

The script reads the key from the env file, builds the request, calls the API, decodes the returned image, and writes the PNG.

### Step 4 — Confirm and report

Confirm the output file was written. Report the saved path and the per-image cost the script prints from `usage.cost`. If the script reports no image in the response, show the raw response and stop rather than claiming success.

## API request shape

OpenRouter generates images through the chat completions endpoint with image output enabled, not the OpenAI images endpoint.

```bash
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "google/gemini-2.5-flash-image",
    "modalities": ["image", "text"],
    "messages": [
      { "role": "user", "content": [
        { "type": "text", "text": "a photorealistic street at dusk" }
      ] }
    ]
  }'
```

For an edit, add an `image_url` item to the same `content` array with a base64 data URL of the source image. For aspect ratio, add `"image_config": {"aspect_ratio": "16:9"}` at the top level.

The returned image arrives base64-encoded inside the response. Confirmed by live test (2026-06-29): the image is at `choices[0].message.images[0].image_url.url` as a `data:image/png;base64,...` data URL; the `data[].b64_json` form is not used by this model. `generate.sh` still checks both known shapes for resilience.

## Cost

Confirmed by live test (2026-06-29): $0.0387 for one 1024x1024 image (1290 image tokens billed as output). The response's `usage.cost` field is authoritative and the script prints it after each run. Underlying token pricing is $0.30 per 1M input tokens and $2.50 per 1M output tokens.

## For other skills

If your skill needs an image, call image-gateway. Run `skills/core-infrastructure/image-gateway/generate.sh` with a prompt, or invoke this skill. Do not write a second copy of the OpenRouter image call anywhere else; one gateway keeps the model choice, key handling, and output convention in a single place.

## Guardrails

- Never write the API key into this skill, into a logged command, or into any committed file; always read it from the env file.
- Never call the OpenRouter image API from another skill directly; route every image request through this gateway.
- Never report success until the output file exists on disk; if the response contains no image, surface the raw response instead.

## Output contract

A single PNG written under the output directory (default `~/Pictures/agent-images/`), named `YYYY-MM-DD-<slug>.png` unless `--out` overrides it, plus a one-line report of the saved path and the per-image cost.

## Verification standard

Do not call the task done until: the command exits zero, the output file exists and is a non-empty PNG (`file` reports PNG image data), and the per-image cost was reported. Build-time test passed on 2026-06-29: produced a 1024x1024 PNG at $0.0387.
