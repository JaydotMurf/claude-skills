---
name: talk-to-published
description: Turn a recorded voice memo into a published page written in your own voice, shipped to a clean URL with a working link preview.
tags: [publishing, writing, transcription, content]
audience: writers, operators, and solo builders
---

# Talk to Published

You record a voice memo on a walk and want it to end up as a finished page that sounds like you. This runbook carries the recording through transcription, idea triage, drafting, layout, and publishing without you re-explaining the standard at any step.

## Outcome

A single published page at a live, shareable URL — drafted in your voice from one idea inside a voice memo, laid out as a self-contained HTML artifact, and shipped with a clean slug, a 1200x630 OG image, and a working link preview.

## Skills it calls

1. `core-infrastructure/media-transcription` — takes the voice-memo audio file; produces a `<media>.transcript/` folder. Hands `transcript.md` to the next step.
2. `research-and-thinking/brain-dump-processor` — takes `transcript.md`; separates it into one section per distinct idea, each with an assessment and a next step. You pick the one idea worth writing; that idea section is handed to the next step.
3. `writing-voice-and-content/my-voice` — takes the chosen idea section; produces a draft in your voice profile, with the register named and the anti-pattern list checked. Hands the finished draft prose to the next step.
4. `core-infrastructure/html-artifacts` — takes the draft prose; produces a self-contained `YYYY-MM-DD-<slug>.html` carrying its own inline style. Hands the `.html` file path to the next step.
5. `web-publishing-and-frontend/site-publisher` — takes the `.html` file; ships it to a live URL with a clean slug, OG image, share title and description, and the correct indexing directive.

## Verification

- The transcript folder exists beside the source with `transcript.md` populated.
- The draft names the register it used and has been checked against the my-voice anti-pattern list.
- The artifact passes the self-contained check (no external asset references).
- The live URL resolves, and the link preview renders the OG image at 1200x630 with the share title and description.
- The publisher's report states the live URL and the indexing state.
