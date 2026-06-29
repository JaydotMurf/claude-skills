---
name: broll-pipeline
description: End-to-end pipeline that turns a finished talking-head video plus its timestamped transcript into animated motion-graphic overlays composited onto the footage at the right moments. A SCOUT subagent picks the moments and writes a manifest, a BUILDER subagent generates Remotion graphics against one shared visual contract, and this orchestrator renders each clip and composites them with ffmpeg, keeping a state file so a long run resumes after interruption. Use when asked to add motion graphics, lower-thirds, stat cards, or animated b-roll overlays to a recorded talk.
tags: [video, motion-graphics, remotion, ffmpeg, broll, pipeline, subagents]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# B-roll Pipeline

Hand it a finished talking-head video and its transcript, and it adds consistent animated overlays — lower-thirds, stat cards, bullet lists — at the moments that earn them. Three pieces do the work: a SCOUT that decides where graphics go, a BUILDER that makes them from one shared visual contract, and this orchestrator that renders and composites. A state file lets a long run pick up where it stopped.

The hard constraint that makes the output look professional is the shared visual contract: every graphic is built from the same palette, type, timing, and layout primitives, so a whole video's overlays look like one designer made them.

## When to use this skill

Invoke it when:

- The user asks to add motion graphics, lower-thirds, stat cards, animated callouts, or b-roll overlays to a recorded talk or interview.
- A finished talking-head video and its transcript both exist and the spoken edit is locked.

Do not invoke it when:

- The spoken flow is not cut yet — run [radio-edit](../radio-edit/SKILL.md) first; graphics get placed against the final timing.
- No transcript exists — run [media-transcription](../../core-infrastructure/media-transcription/SKILL.md) first.
- The user wants editing done inside their NLE project (silence removal, subclips) rather than rendered overlays — that is [nle-assistant](../nle-assistant/SKILL.md).

## Saved defaults

Chosen at build time because the interview the build prompt asks for could not be run. Confirm with the user on first real use.

- Visual contract: a neutral professional palette and Inter type, defined in `visual-contract.tsx`. Replace `COLORS` and `FONTS` with the user's real brand before a real render; nothing else changes.
- Density: about 1.5 graphics per minute, minimum 12-second gap. The SCOUT enforces both.
- Output: 1920x1080 at 30 fps, H.264 final file for horizontal platforms (YouTube). For vertical (Reels/Shorts) set the manifest `width`/`height` to 1080x1920.

## Architecture

Three pieces, in `this skill folder`:

- SCOUT (`scout.md`) — a subagent. Reads the chaptered transcript, picks moments, enforces density and spacing, writes `manifest.json`.
- BUILDER (`builder.md`) — a subagent. Takes 2–3 manifest entries at a time and generates Remotion components, importing only from `visual-contract.tsx`.
- ORCHESTRATOR (this skill, `orchestrate.sh`) — renders each graphic to a transparent ProRes clip, composites them onto the source with ffmpeg, and tracks progress in `pipeline-state.json`.

Supporting files: `visual-contract.tsx` (the shared contract), `Root.tsx` and `index.ts` (Remotion registration with the parametric `Graphic` composition), `manifest.example.json` (the manifest schema).

## Steps

Build and run in stages; verify each before the next.

### Step 1 — Stand up the contract and approve one reference graphic

Copy this folder's `*.tsx` and `index.ts` into a Remotion project (`npm create video@latest` or an existing one), set `COLORS`/`FONTS` to the user's brand, and render the `Reference` composition. Get the user to approve that one graphic's look before any others are generated. This is the design gate.

### Step 2 — Run the SCOUT

Invoke the SCOUT subagent (`scout.md`) with the transcript and the density/spacing/output parameters. It writes `manifest.json`. Sanity-check the manifest: count, spacing, and that every `type` is one the contract supports.

### Step 3 — Run the BUILDER in batches

For any manifest `type` not already in `GraphicRouter`, invoke the BUILDER subagent (`builder.md`) on 2–3 entries at a time. It extends `visual-contract.tsx` and `Root.tsx` using only contract tokens. Validate each batch (`npx remotion compositions index.ts` lists `Graphic` with no TypeScript error) before the next.

### Step 4 — Initialize the pipeline

```bash
./orchestrate.sh init manifest.json talk.mp4
```

This writes `pipeline-state.json` and creates `clips/`.

### Step 5 — Render and composite

```bash
./orchestrate.sh run        # render every graphic, then composite onto the video
```

`render` renders each manifest entry to `clips/<id>.mov` (transparent ProRes 4444), skipping any clip that already exists, so an interrupted run resumes. `composite` overlays every clip onto the source at its `in`/`out` time with ffmpeg and writes `final.mp4`. Run `./orchestrate.sh status` any time to see progress.

### Step 6 — Review the final video

Play `final.mp4`. Confirm each graphic appears at the right moment, reads cleanly over the footage, and matches the others. Re-run a single graphic by deleting its clip and running `render` again.

## Output contract

In the pipeline working directory:

- `manifest.json` — the moment list (SCOUT output): `video`, `fps`, `width`, `height`, and `graphics[]` each with `id`, `in`, `out`, `type`, `concept`, and `data`.
- `clips/<id>.mov` — one transparent ProRes 4444 clip per graphic.
- `final.mp4` — the source video with every overlay composited at its timestamp.
- `pipeline-state.json` — stage tracking for resume.

## Guardrails

- Never let a graphic use a color, font, animation curve, or layout that is not defined in `visual-contract.tsx`; the contract is extended once and reused, never bypassed per graphic.
- Never exceed the density target or the minimum gap; a wall of graphics is the failure mode the SCOUT exists to prevent.
- Never paint a full-frame opaque background in a graphic; overlays must render on transparency or they will hide the footage.
- Never modify or overwrite the source video; all output goes to `clips/` and `final.mp4`.

## Verification standard

Do not call the task done until: the `Reference` graphic was approved before others were generated; `manifest.json` is valid and respects density and spacing; every manifest `type` resolves in `GraphicRouter` with no TypeScript error; `clips/<id>.mov` exists for every entry; and `final.mp4` exists with each overlay visible at its timestamp. Build-time static test (2026-06-29): `orchestrate.sh` passed `bash -n`; the example manifest passed jq schema checks (non-empty graphics, `in < out`, supported types, unique ids); `init`/`status` produced correct state; and `composite`/`render` failed cleanly with clear messages when a dependency (ffmpeg) or a rendered clip was missing. The Remotion render, ffmpeg composite, and TypeScript compile run at first real use inside a Remotion project; the orchestration logic, manifest schema, alpha-render flags (`--codec=prores --prores-profile=4444 --pixel-format=yuva444p10le`, confirmed against Remotion docs), and ffmpeg overlay graph were verified by static analysis, not by a full paid render.

## Notes

This is the heaviest skill in the library: it composes a subagent architecture, a React-video renderer, and a compositing step. The split is deliberate — SCOUT decides, BUILDER makes, orchestrator assembles — so each stage is independently verifiable and a failure in one does not silently corrupt the others.
