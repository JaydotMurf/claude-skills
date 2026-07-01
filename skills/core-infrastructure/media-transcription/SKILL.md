---
name: media-transcription
description: Turn a local audio or video file into a complete transcription package (readable transcript, word-level timestamps, chapters, speaker labels) using the AssemblyAI API. Use when given a media file and asked for a transcript, captions, chapters, or to make a recording searchable. Other skills that need a transcript call this.
tags: [transcription, assemblyai, media, core-infrastructure]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Media Transcription

Hand it a local audio or video file and it produces a standard transcription package next to the source: a readable transcript, word-level timestamps, semantic chapters, and speaker labels. The package format is fixed so editing and research skills downstream can rely on it.

## When to use this skill

Invoke it when:

- The user gives a media file path and asks for a transcript, captions, or subtitles.
- The user asks for chapters, a summary structure, or to make a recording searchable.
- Another skill needs a transcript of a recording before it can act.

Do not invoke it for files that are already text, or for remote videos that have not been downloaded to a local path.

## Saved defaults

- Models: `["universal-3-pro", "universal-2"]`, AssemblyAI's current default priority order.
- Output: a `<media-without-ext>.transcript/` folder next to the source media.
- API key: read from `~/.config/agent-skills/.env`. Resolution order is `MEDIA_TRANSCRIPTION_API_KEY`, then `ASSEMBLYAI_API_KEY`. The key is never written into this skill.

## Steps

### Step 1 — Confirm the input

Confirm the media path exists and is local. Decide whether speaker diarization and chapters are wanted (both default on; pass `--no-diarization` or `--no-chapters` to turn off). Completion: you have a readable local file path.

### Step 2 — Confirm the key is present

Check that `~/.config/agent-skills/.env` defines `ASSEMBLYAI_API_KEY` or `MEDIA_TRANSCRIPTION_API_KEY`. If neither is set, stop and tell the user to add `ASSEMBLYAI_API_KEY` (generate one at assemblyai.com → account). Do not proceed without a key.

### Step 3 — Run the transcription

Run the script in this skill folder:

```bash
./transcribe.sh path/to/media [--no-diarization] [--no-chapters]
```

For a video source the script extracts audio with ffmpeg first, then uploads, creates the job, and polls until it completes.

### Step 4 — Confirm the package

Confirm the `<media>.transcript/` folder exists and contains the four artifacts. Report the folder path and list its contents. If the job returned an error or no text, surface that and stop rather than reporting success.

## The request flow

Three steps against AssemblyAI, all with the header `Authorization: <key>` (no Bearer prefix):

```bash
# 1. upload the local file -> returns { "upload_url": "..." }
curl -X POST https://api.assemblyai.com/v2/upload \
  -H "Authorization: $ASSEMBLYAI_API_KEY" --data-binary @audio.m4a

# 2. create the job with that url
curl -X POST https://api.assemblyai.com/v2/transcript \
  -H "Authorization: $ASSEMBLYAI_API_KEY" -H "Content-Type: application/json" \
  -d '{"audio_url":"...","speech_models":["universal-3-pro","universal-2"],
       "speaker_labels":true,"auto_chapters":true}'

# 3. poll until status == "completed"
curl https://api.assemblyai.com/v2/transcript/ID -H "Authorization: $ASSEMBLYAI_API_KEY"
```

The completed response carries `text`, `words[]` (each with `text`, `start`, `end`, `confidence`, `speaker`), `utterances[]` (speaker turns), `chapters[]` (`headline`, `gist`, `summary`, `start`, `end`), and `audio_duration` in seconds. Confirmed by live test (2026-06-29): the `speech_models` array is accepted (the response echoes `speech_model: null`, which is expected), and AIFF input from macOS `say` uploaded and transcribed without conversion.

## Output contract

A `<media>.transcript/` folder next to the source, with these fixed filenames so downstream skills know exactly where to look:

- `transcript.json` — the full raw API response, the source of truth.
- `transcript.md` — readable, with `[H:MM:SS] Speaker A: ...` lines when diarization is on.
- `words.json` — the word-level timestamp array.
- `chapters.md` — semantic chapters with timestamps.

## For other skills

If your skill needs a transcript, call media-transcription and read the artifacts from `<media>.transcript/`. Do not call AssemblyAI from another skill. Keeping one transcription gateway means the output format stays consistent for every skill that consumes it.

## Cost and caveats

AssemblyAI bills by audio duration, not per request, and the transcript response carries no cost field (use `audio_duration` seconds to estimate). Confirmed by live test (2026-06-29): a 16-second clip transcribed for a tiny fraction of a cent. Re-validated 2026-07-01: a 25-second two-topic clip (`audio_duration: 25`) produced all four artifacts with accurate speaker-labeled text, 65 word timestamps, and one auto-chapter, again for well under a cent. Confirm current per-hour rates at assemblyai.com/pricing. AssemblyAI flags `auto_chapters` as deprecated in favor of its newer summarization gateway, so the chapters step may need migration later; it still returns chapters today. The `speech_models` array field is current; older code used a singular `speech_model` string.

Dependencies: `curl` and `jq` always; `ffmpeg` only for video sources, to extract audio before upload. Audio inputs need no ffmpeg. On macOS install it with `brew install ffmpeg`.

## Guardrails

- Never write the API key into this skill or a logged command; always read it from the env file.
- Never call the AssemblyAI API from another skill; route transcription through this one so the package format stays consistent.
- Never report success until the `<media>.transcript/` folder exists with its artifacts and the job status was `completed`.

## Verification standard

Do not call the task done until: the script exits zero, the job reached status `completed`, and the output folder contains `transcript.json`, `transcript.md`, `words.json`, and `chapters.md` with non-empty transcript text. Build-time test passed on 2026-06-29: a 16-second clip produced the full four-artifact package with accurate speaker-labeled text, word timestamps, and a chapter. Live re-validated 2026-07-01: a 25-second clip produced the same four-artifact package (status `completed`, 65 words, one chapter) with all files non-empty.
