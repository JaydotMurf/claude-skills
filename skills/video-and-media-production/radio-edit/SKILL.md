---
name: radio-edit
description: Produce a transcript-driven rough cut of talking-head footage — fix the spoken flow before any visual work. Reads a media-transcription word-level transcript, proposes a paper edit (every cut with timecodes, what was removed, and why) for human review FIRST, then exports an NLE timeline (CMX3600 EDL or FCPXML 1.13) with the approved cuts and a frame handle on each. Use when asked for a rough cut, paper edit, or cleaned-up edit of a recording.
tags: [video, editing, rough-cut, paper-edit, edl, fcpxml, transcript]
audience: engineers, operators, and solo builders
source: open-skills
---

# Radio Edit

Hand it a talking-head video that already has a transcript, and it fixes the spoken flow before any visual work touches the footage. It removes filler, dead air, stutters and false starts, repeated takes, and any phrase you said must always go. It writes a human-readable paper edit you approve first, then exports a timeline your editor can import.

The name is the radio-edit idea from audio production: cut the words until the talk sounds right, then hand the result to picture.

## When to use this skill

Invoke it when:

- The user asks for a rough cut, paper edit, paper cut, or cleaned-up edit of a recording.
- The user has a talking-head or interview recording and wants the rambling tightened before they open their editor.
- A later media skill needs a cut-down timeline before adding b-roll or grading.

Do not invoke it when:

- No transcript exists yet — run [media-transcription](../../core-infrastructure/media-transcription/SKILL.md) first; this skill consumes its `<media>.transcript/words.json`.
- The ask is visual: b-roll, motion graphics, color, or compositing (that is [broll-pipeline](../broll-pipeline/SKILL.md) or [nle-assistant](../nle-assistant/SKILL.md)).
- The source is scripted/performance footage where every take is deliberate and nothing should be auto-removed.

## Saved defaults

These were chosen at build time because the interview the build prompt asks for could not be run (no live user). Each is overridable per run; confirm them with the user on first real use.

- NLE format: `edl` (CMX3600). It imports into Premiere, Resolve, Avid, and FCP, so it is the safe default. Pass `--format fcpxml` for a Final Cut Pro 11 FCPXML 1.13 file instead.
- Aggression: `balanced` — removes clear filler, stutters, repeated takes, and dead air over 700 ms, but leaves conversational rhythm. Alternatives: `tight` (also trims soft filler like "actually"/"basically" and pauses over 350 ms) and `conversational` (only obvious filler and long pauses, no repeated-take removal).
- Always-cut list: empty. Supply one with `--always-cut file.txt` (one phrase per line: profanity, names, anything that must never survive).
- Frame rate: 30 fps. Pass `--fps` to match the footage (e.g. `--fps 23.976` reads as 24 for non-drop timecode).
- Handles: 6 frames left on each cut so the editor can finesse the trim.

## Steps

### Step 1 — Confirm the transcript exists

Confirm a `<media>.transcript/` folder with `words.json` sits next to the source video. If not, stop and run media-transcription first. Completion: a readable `words.json` path.

### Step 2 — Confirm the edit parameters

Confirm with the user (or fall back to the saved defaults and state which you used): NLE format, aggression, frame rate, and any always-cut phrases. Record any assumption you make in your reply.

### Step 3 — Generate the paper edit

Run the script in this folder:

```bash
./radio-edit.py path/to/video.mp4 --format edl --aggression balanced --fps 30
```

It writes `paper-edit.md` and the timeline into `<media>.radioedit/`. Open `paper-edit.md`, do not open the timeline yet.

### Step 4 — Deliver the paper edit for review FIRST

Show the user `paper-edit.md`: source vs edited runtime, and every cut with in/out timecodes, the removed text, and the reason. Do not present the timeline as final until the user has seen the cut list. This is the review gate.

### Step 5 — Revision loop

The user marks up `paper-edit.md` — writing `KEEP` next to any cut they want restored, or pointing out a take you kept that they want swapped. Adjust and re-run: move a wrongly-cut phrase into a `--keep` exception by loosening aggression or adding it to an always-keep note, or change the aggression level, then regenerate. Repeat until the user signs off on the cut list.

### Step 6 — Hand over the timeline

Once the paper edit is approved, point the user to the timeline file (`edit.edl` or `edit.fcpxml`) and tell them how to import it (Premiere: File → Import; Resolve: File → Import → Timeline; FCP: File → Import → XML). Confirm the import lands the expected number of clips.

## How the cuts are decided

- Filler: a fixed set of filler tokens (`um`, `uh`, `er`, `hmm`, plus phrases `you know`, `i mean`, `sort of`, `kind of`). Soft filler (`actually`, `basically`, `literally`, `honestly`, `like`) is only removed at `tight`.
- Stutters / false starts: an immediately repeated word (`the the`) drops the first.
- Repeated takes: a run of 3–6 words restated back-to-back keeps the later, usually cleaner take and cuts the first, and the paper edit says so.
- Dead air: a pause between kept words longer than the aggression threshold becomes a cut.
- Always-cut: any supplied phrase is removed wherever it appears, no matter what.

Timecodes come from the word-level `start`/`end` (milliseconds) in `words.json`, converted to non-drop `HH:MM:SS:FF` at the chosen fps. Handles extend each kept segment by the handle amount, clamped to the midpoint of the removed gap so neighbouring clips never overlap.

## Output contract

A `<media>.radioedit/` folder next to the source, containing:

- `paper-edit.md` — the review document: runtime before/after, a numbered cut list (timecode in/out, removed text, reason), and the kept segments in order. Delivered to the human before the timeline.
- `edit.edl` (default) or `edit.fcpxml` — the timeline with the kept segments assembled on one track, contiguous record timecodes, and a frame handle on each cut.

The EDL is CMX3600 non-drop with `AA/V` events and a `FROM CLIP NAME` comment per event. The FCPXML targets version 1.13 (Final Cut Pro 11): one asset, one spine of `asset-clip` segments carrying sync audio and video.

## Guardrails

- Never deliver or describe the timeline as final before the user has reviewed `paper-edit.md`; the paper edit is the approval gate.
- Never call an external API or upload the media — this skill is local-only and needs no key.
- Never silently drop a repeated take; every removed take must appear in the paper edit with its reason and a note that the later take was kept.
- Never overwrite the source media; all output goes to the separate `<media>.radioedit/` folder.

## Verification standard

Do not call the task done until: the script exits zero; `paper-edit.md` exists and lists every cut with timecodes and reasons; the timeline file exists; the timeline is structurally valid (EDL record timecodes are contiguous with no overlap, or the FCPXML parses as well-formed XML against version 1.13); and the user has seen the paper edit before the timeline was handed over. Build-time static test (2026-06-29): on a synthetic 12.4 s transcript exercising filler, a stutter, a repeated take, dead air, an always-cut name, and a filler phrase, the script produced a 6-segment cut, kept the later of two identical takes, wrote contiguous EDL record timecodes, emitted well-formed FCPXML 1.13, and failed cleanly with a clear message when pointed at a missing transcript. End-to-end import into a real NLE on real footage is left for first live use; the timeline formats were validated structurally, not by a round-trip through an editor.
