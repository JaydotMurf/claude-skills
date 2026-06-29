---
name: branded-image-prompting
description: Generate on-brand images by encoding the user's visual identity as prompt-ready guidance plus a reusable prompt-template library, then routing actual generation through the image-gateway skill. Use for any branded or recurring-format image request (thumbnails, diagrams, infographics, social images, mockups). Includes corrective recipes for color, text, and style drift, and grows the library from prompts that worked.
tags: [images, branding, prompting, content, media]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Branded Image Prompting

Encodes the user's visual identity once (brand colors, typography direction, overall style) and turns it into prompt-ready guidance the agent applies by default to every image request. It carries a starter library of prompt templates for the user's common formats, corrective recipes for the usual ways image models drift, and a rule that every actual image is generated through the image-gateway skill, never through a second image API call written here. Prompts that produce a good result are written back to the library so it compounds.

## When to use this skill

Invoke it when:

- The user asks for any branded image (thumbnail, diagram, infographic, social image, mockup).
- The user asks for an image in a recurring format that should match prior work.

Do not invoke it for one-off images with no brand requirement, for finding or editing existing photos, or for cropping and resizing that needs no generation.

## Saved defaults

- Brand profile path: `~/.config/agent-skills/brand-profile.md`, holding brand colors (hex), typography direction, overall visual style, reference image paths, and common formats. Assumption recorded on build: this matches the other agent-skills profiles. Override with `BRAND_PROFILE_PATH`.
- User prompt library path: `~/.config/agent-skills/brand-prompt-library.md`. The starter templates below seed it; prompts that work get appended here so the library stays personal and out of any repo.
- Generation always runs through the image-gateway skill, whose default model is `google/gemini-2.5-flash-image`. That gateway owns the API shape, the key, and the output convention; this skill owns the prompts.

## Steps

### Step 1 — Load or build the brand profile

Read `~/.config/agent-skills/brand-profile.md`. If it exists, load it. If it does not, interview the user for: brand colors as hex values, typography direction, overall visual style (with reference image paths if they have them), and their most common image formats. Write the answers to the profile file. Completion: you hold brand colors, typography direction, style, and the common formats.

### Step 2 — Restate the brand guidelines in prompt-ready language

Turn the profile into a guidance block written the way an image model reads best: name the exact hex colors and where they go, the typographic feel, the lighting and composition style, and what to avoid. This block prefixes every prompt by default. Completion: a reusable brand guidance block exists.

### Step 3 — Choose the prompt form

Write the prompt in one of two forms and say why. Natural-language prose works better for mood, scene, and photographic style where the model fills gaps tastefully. JSON-structured prompts work better when exact control matters: fixed palette, specific layout, repeatable format across a series. Completion: a prompt drafted in the chosen form with the brand guidance applied.

### Step 4 — Pull from the library

Start from the matching template in the library below (or the user library), then fill its slots with the request specifics. Do not write a branded prompt from scratch when a template covers the format. Completion: the prompt is built from a named template.

### Step 5 — Generate through the gateway

Hand the finished prompt to the image-gateway skill to produce the image. Do not call any image API directly from this skill. Completion: image-gateway returns a saved image path and cost.

### Step 6 — Inspect and correct drift

Check the result against the brand. If it drifted, apply the matching corrective recipe below and regenerate through the gateway. Completion: the image matches the brand guidance, or the user accepts it.

### Step 7 — Write the winner back to the library

When a prompt produces an accepted image, append it to `~/.config/agent-skills/brand-prompt-library.md` under its format, with a one-line note on what it produced. Completion: the successful prompt is saved to the user library.

### Step 8 — Test

On first build, generate one thumbnail and one diagram in the brand and show both for judgment. Completion: a thumbnail and a diagram exist and the user has judged them.

## Prompt forms

Natural-language example:

```
{brand guidance block}. A {subject}, {composition}, {lighting/mood},
in the brand style. Primary color {hex}, accent {hex}. No text.
```

JSON-structured example (hand the assembled prompt text to image-gateway):

```json
{
  "subject": "<what the image shows>",
  "format": "thumbnail | diagram | infographic | social | mockup",
  "palette": { "primary": "#RRGGBB", "accent": "#RRGGBB", "background": "#RRGGBB" },
  "typography": "<direction, only if text is required>",
  "composition": "<layout, focal point, aspect>",
  "style": "<overall look>",
  "avoid": ["off-brand colors", "stock-photo cliches", "garbled text"]
}
```

## Starter prompt library

Seed the user library with these. Each is a template; fill the braces from the request and the brand profile.

1. YouTube thumbnail — bold focal subject left, {short 2–4 word hook} right in brand type, primary {hex} background, high contrast, 16:9.
2. Blog hero — wide {subject} scene in brand style, accent {hex} highlight, generous negative space for an overlaid headline, 16:9.
3. Concept diagram — clean labeled flow of {N} nodes, brand palette only, flat vector look, even spacing, white or {hex} background.
4. Architecture diagram — boxes and arrows for {system}, primary {hex} for components and accent {hex} for data flow, monospace-feel labels.
5. Infographic panel — single statistic {stat} as the hero number in brand type, one supporting icon, accent {hex}, square.
6. Step infographic — {N} numbered steps top to bottom, consistent icon style, brand palette, vertical format.
7. Social square — {subject} centered, brand color field, room for a short caption band, 1:1.
8. Social story — vertical {subject} with brand gradient from {hex} to {hex}, 9:16.
9. Quote card — pull-quote "{quote}" in brand type on a {hex} field, small attribution line, square.
10. Product mockup — {product} shown in {context}, brand style lighting, accent {hex} surfaces, realistic but clean.
11. UI mockup — a {screen} for {product}, brand palette applied to the interface, flat modern style, on a neutral background.
12. Comparison graphic — two-column {A vs B} layout, brand colors split left and right, clear labels, 16:9.

## Corrective recipes

- Wrong colors — restate the exact hex values and say "use only these colors", then name the off-brand color seen and forbid it explicitly.
- Mangled or invented text — for text-bearing images, give the exact string in quotes and keep it short; if it still garbles, generate text-free and add type in a layout tool, and note this in the prompt.
- Off-style result — add two or three concrete style anchors (medium, lighting, composition) and an explicit "avoid" list rather than vague adjectives.
- Cluttered composition — specify one focal subject, state the negative space, and cap the element count.
- Wrong aspect or crop — set the aspect ratio in the gateway call and restate it in the prompt.

## Guardrails

- Never call an image API directly from this skill; route every generation through the image-gateway skill so model, key, and output convention stay in one place.
- Never write a brand color, typography choice, or reference path into this skill or a committed file; read them from the brand profile.
- Never present a generated image as on-brand without checking it against the brand guidance first.
- Never let a prompt that produced a good image go unsaved; append it to the user library.

## Output contract

A brand-ready image prompt (natural-language or JSON-structured) built from a named library template and prefixed with the brand guidance block, the resulting image produced through image-gateway with its saved path and cost, and an appended entry in `~/.config/agent-skills/brand-prompt-library.md` for any prompt that produced an accepted image.

## Verification standard

Do not call the task done until: the prompt was built from a named template and carries the brand guidance, generation ran through image-gateway (not a direct API call), the image was checked against the brand and any drift corrected, and a successful prompt was written back to the user library. Build-time test: generate one thumbnail and one diagram in the brand and confirm the user judges them.
