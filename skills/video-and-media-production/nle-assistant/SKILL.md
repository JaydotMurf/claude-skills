---
name: nle-assistant
description: Operate DaVinci Resolve through its Python scripting API to do transcript-driven editing inside a real project — verify the connection, duplicate a timeline as a safety copy, remove silences, extract subclips, and assemble a timeline from a transcript-derived edit list. Use when an editing request should happen inside the editor (remove silences, pull clips matching a description, build a rough timeline from footage) rather than as a rendered file. Driven by media-transcription transcripts.
tags: [video, davinci-resolve, scripting-api, editing, transcript, nle]
audience: engineers, operators, and solo builders
source: open-skills
---

# NLE Assistant

Drives DaVinci Resolve directly through its Python scripting API so editing happens inside the real project: connect, duplicate the timeline for safety, then do transcript-driven work like silence removal and subclip assembly. The transcript that drives the edits comes from media-transcription.

## When to use this skill

Invoke it when:

- The user asks for an edit that should happen inside DaVinci Resolve: remove silences from a clip, pull clips matching a description, or build a rough timeline from footage.
- The user wants changes applied to their actual project, not exported as a separate file.

Do not invoke it when:

- The user wants a portable timeline file to import elsewhere (EDL/FCPXML) — that is [radio-edit](../radio-edit/SKILL.md).
- The user wants rendered motion-graphic overlays — that is [broll-pipeline](../broll-pipeline/SKILL.md).
- DaVinci Resolve is not the editor, or only the free version is available — external scripting requires Resolve Studio.

## Saved defaults and assumptions

Chosen at build time without a live interview. Confirm on first real use.

- Editor: DaVinci Resolve Studio (the build prompt specifies Resolve; its Python API ships with the app). External scripting needs Studio; the free version scripts only from its internal console.
- Silence threshold: a gap longer than 700 ms between spoken words counts as silence. Pass `--gap-ms` to change it.
- Frame rate: 30 fps for converting transcript milliseconds to frames. Pass `--fps` to match the project.

## Connection procedure and failure modes

The script imports `DaVinciResolveScript` (shipped with the app), falling back to the default per-OS module path, then calls `scriptapp("Resolve")`. Failure modes are reported explicitly:

- App not running / module unreachable: `scriptapp` returns nothing → "cannot reach DaVinci Resolve. Is the app running? Studio required."
- No project open: `GetCurrentProject()` returns nothing → "no project is open."
- No timeline: `GetCurrentTimeline()` returns nothing → "no current timeline."

Always run `connect` first and confirm it reports the expected project before any edit.

## Steps

### Step 1 — Verify the connection

```bash
python3 nle.py connect
```

Confirm it prints the Resolve version, the open project's name, the timeline count, and the current timeline. If it fails, fix the cause it names (open the app, open a project, open a timeline) before continuing.

### Step 2 — Make the safety copy

Never edit an original. Every editing subcommand duplicates the current timeline first and works on the copy, but you can also do it explicitly:

```bash
python3 nle.py duplicate --name "edit pass 1"
```

### Step 3 — Run the transcript-driven edit

For silence removal, point at the clip and its transcript folder:

```bash
python3 nle.py silence-removal --clip "interview_A.mov" --transcript path/to/interview_A.transcript --gap-ms 700 --fps 30
```

It duplicates the timeline for safety, reads `words.json`, computes the spoken (non-silence) ranges, and builds a new timeline containing only those frame ranges of the clip.

### Step 4 — Review in the app before touching anything real

Switch to DaVinci Resolve and inspect the new timeline. Confirm the cuts land where expected and the original timeline is unchanged. Only after the user approves on a throwaway project should this run against real work.

## Core operations

Each is exercised on its own before being combined:

- Connect and read project / timeline state (`connect`).
- Duplicate a timeline (`duplicate`) — the safety primitive.
- Find a clip in the media pool by name (used by `silence-removal`).
- Convert a transcript into kept frame ranges and assemble a new timeline from subclip ranges (`silence-removal`, via `AppendToTimeline`).
- Offline math check (`selftest`) that the transcript-to-frame logic is correct without needing Resolve.

## Guardrails

- Never modify or delete an original timeline or any media; always duplicate the timeline and work on the copy. Every editing path in the script duplicates before it edits.
- Never run against a real project until the same operation has been verified on a throwaway project and the user has reviewed the result in the app.
- Never report success when `connect` failed or a clip was not found; surface the exact failure mode and stop.
- Never call an external API or upload media — this skill is local to the running Resolve app and needs no key.

## Output contract

- `connect` prints the Resolve version, project name, timeline count, and current timeline.
- `duplicate` creates a named copy of the current timeline and reports the new name.
- `silence-removal` creates a safety copy plus a new "<clip> — silences removed" timeline, and reports how many spoken ranges were kept and how much silence was removed.

## Verification standard

Do not call the task done until: `connect` reports the expected project; the operation made a duplicate and left the original timeline unchanged; and the result was reviewed in the app on a throwaway project before any real edit. Build-time test (2026-06-29): the connection pattern (`scriptapp("Resolve")` → `GetProjectManager` → `GetCurrentProject`) was verified against current DaVinci Resolve scripting docs; `python3 -m py_compile` passed; `selftest` confirmed the kept-range and millisecond-to-frame math; and `connect` failed cleanly with an actionable message when Resolve was not reachable. The live duplicate-and-silence-removal round trip runs at first real use against a running Resolve Studio instance (not available in the build environment); the connection handling, media-pool search, and timeline-assembly calls were verified by static analysis and against the API docs, not by a live session.
