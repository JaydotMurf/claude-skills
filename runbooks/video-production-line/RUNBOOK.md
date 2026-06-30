---
name: video-production-line
description: Turn raw talking-head footage into a finished, graphics-laden edit with the editorial decisions front-loaded onto a paper edit you approve before any timeline is built.
tags: [video, editing, transcription, media]
audience: video producers, solo operators, content teams
---

# The Video Production Line

Raw talking-head footage in, finished video with motion graphics out. The editorial work happens on paper first, where it is cheap to change, before any frame is assembled.

## Outcome

A finished video assembled in your NLE from approved footage, carrying consistent animated b-roll overlays, with a stakeholder update sent telling your editor or client it is ready for review.

## Skills it calls

1. `core-infrastructure/media-transcription` — takes the raw footage; produces a `<media>.transcript/` folder with `words.json` word-level timestamps and `chapters.md`. Hands the timestamped transcript to the next step.
2. `video-and-media-production/radio-edit` — takes the transcript; produces a `<media>.radioedit/` folder with `paper-edit.md` (a numbered cut list you approve) and `edit.edl` (the kept segments assembled on one track). The paper edit goes to you for approval before the EDL is handed to the next step.
3. `video-and-media-production/broll-pipeline` — takes the approved cut; scouts it for graphic-worthy moments into `manifest.json`, generates one transparent ProRes 4444 clip per moment, and composites `final.mp4`. Hands the overlay clips and manifest to the next step.
4. `video-and-media-production/nle-assistant` — takes the assembled cut and overlays; connects to DaVinci Resolve, makes a safety copy, and builds the timeline, never editing an original. Hands the finished timeline name to the next step.
5. `agent-operations/stakeholder-update-email` — takes the finished timeline's verified state; drafts a what-changed / what-it-means / what's-next update and, on confirmation, sends it.

## Verification

- The transcript folder exists with `words.json` populated; every later step reads from it.
- The paper edit was delivered and approved before the timeline was built.
- `final.mp4` exists with every overlay composited at its manifest timestamp.
- The NLE step worked on a safety copy, confirmed by the duplicated timeline name, with no original modified.
- The update email claims only the verified ready-for-review state.
