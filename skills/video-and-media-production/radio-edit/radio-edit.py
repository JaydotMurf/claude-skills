#!/usr/bin/env python3
# radio-edit: turn a word-level transcript into a transcript-driven rough cut of
# talking-head footage. Fixes the spoken flow first — removes filler, dead air,
# stutters/false starts, repeated takes, and any always-cut phrases — then writes
# a human-readable paper edit AND an NLE timeline (CMX3600 EDL or FCPXML 1.13).
#
# Input is the media-transcription package: a "<media>.transcript/" folder holding
# words.json (AssemblyAI word array, start/end in MILLISECONDS). No API key, no
# network — this is pure local processing.
#
# Usage:
#   radio-edit.py <media-or-transcript-folder> [options]
#
#   <media-or-transcript-folder>  path to the source video, or to its
#                                 "<media>.transcript/" folder, or to words.json.
#
# Options:
#   --fps N            timeline frame rate (default 30)
#   --aggression LEVEL tight | balanced | conversational (default balanced)
#   --handles N        frames left on each cut for finesse (default 6)
#   --gap-ms N         dead-air threshold in ms; longer pauses get trimmed
#                      (default depends on aggression)
#   --always-cut FILE  newline-separated phrases that must always be removed
#                      (profanity, names); case-insensitive
#   --reel NAME        EDL reel name for the source (default AX)
#   --format FMT       edl | fcpxml (default edl)
#   --out DIR          output folder (default "<media>.radioedit/" next to source)
#
# Output (always both files):
#   paper-edit.md   every cut: timecode, removed text, reason; runtime before/after.
#                   This is delivered to the human FIRST, before the timeline.
#   edit.edl        CMX3600 EDL  (when --format edl)   OR
#   edit.fcpxml     FCPXML 1.13  (when --format fcpxml)
#
# Revision loop: the human marks up paper-edit.md (e.g. adds "KEEP" next to a cut),
# the agent re-runs with the corrected keep list. Mechanism documented in SKILL.md.

import argparse
import json
import os
import re
import sys
from xml.sax.saxutils import escape

FILLER = {
    "um", "uh", "erm", "er", "ah", "uhh", "umm", "hmm", "mhm", "mm",
    "like", "basically", "literally", "actually", "honestly",
}
# Multi-word filler phrases (checked on the lowercased token stream).
FILLER_PHRASES = [
    ["you", "know"], ["i", "mean"], ["sort", "of"], ["kind", "of"],
    ["you", "know", "what", "i", "mean"],
]

# Aggression presets: which removal classes are on, and the dead-air threshold.
PRESETS = {
    "tight": {"gap_ms": 350, "filler": True, "soft_filler": True, "stutter": True, "repeat": True},
    "balanced": {"gap_ms": 700, "filler": True, "soft_filler": False, "stutter": True, "repeat": True},
    "conversational": {"gap_ms": 1100, "filler": True, "soft_filler": False, "stutter": True, "repeat": False},
}
# "soft" filler are words that are only filler in context (like, actually, honestly).
SOFT_FILLER = {"like", "basically", "literally", "actually", "honestly"}


def fail(msg):
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def find_words_json(path):
    if os.path.isfile(path) and path.endswith(".json"):
        return path
    if os.path.isdir(path):
        cand = os.path.join(path, "words.json")
        if os.path.isfile(cand):
            return cand
        fail(f"no words.json inside {path}. Run media-transcription on the video first.")
    # treat as a media file: look for "<media>.transcript/words.json"
    base = os.path.splitext(path)[0]
    cand = os.path.join(base + ".transcript", "words.json")
    if os.path.isfile(cand):
        return cand
    fail(f"could not locate words.json for {path}. Expected {cand}. "
         "Run media-transcription first to produce the transcript package.")


def load_words(words_path):
    with open(words_path) as fh:
        data = json.load(fh)
    # Accept either a bare array or { "words": [...] }.
    words = data.get("words", data) if isinstance(data, dict) else data
    if not isinstance(words, list) or not words:
        fail(f"{words_path} holds no words. Cannot build an edit.")
    out = []
    for w in words:
        try:
            out.append({
                "text": str(w["text"]),
                "start": int(w["start"]),   # ms
                "end": int(w["end"]),       # ms
                "conf": float(w.get("confidence", 1.0)),
                "speaker": w.get("speaker"),
            })
        except (KeyError, TypeError, ValueError):
            fail("words.json is not in the expected AssemblyAI shape "
                 "(each word needs text/start/end). Re-run media-transcription.")
    return out


def norm(tok):
    return re.sub(r"[^a-z0-9']", "", tok.lower())


def mark_removals(words, preset, always_cut):
    """Return a parallel list of removal reasons (None means keep)."""
    n = len(words)
    reason = [None] * n
    toks = [norm(w["text"]) for w in words]

    # always-cut phrases (multi-word, case-insensitive)
    for phrase in always_cut:
        plen = len(phrase)
        if plen == 0:
            continue
        for i in range(n - plen + 1):
            if toks[i:i + plen] == phrase:
                for j in range(i, i + plen):
                    reason[j] = "always-cut phrase"

    # filler words
    for i, t in enumerate(toks):
        if reason[i]:
            continue
        if t in FILLER and (preset["soft_filler"] or t not in SOFT_FILLER):
            reason[i] = "filler"

    # filler phrases
    for phrase in FILLER_PHRASES:
        plen = len(phrase)
        for i in range(n - plen + 1):
            if any(reason[j] for j in range(i, i + plen)):
                continue
            if toks[i:i + plen] == phrase:
                for j in range(i, i + plen):
                    reason[j] = "filler phrase"

    # immediate single-word stutters: "the the", "I I"
    if preset["stutter"]:
        for i in range(1, n):
            if reason[i] or reason[i - 1]:
                continue
            if toks[i] and toks[i] == toks[i - 1]:
                reason[i - 1] = "stutter (repeated word)"

    # repeated takes / false starts: a run of >=3 words immediately restated.
    if preset["repeat"]:
        for span in (6, 5, 4, 3):
            i = 0
            while i + 2 * span <= n:
                a = toks[i:i + span]
                b = toks[i + span:i + 2 * span]
                if all(a) and a == b and not any(reason[i:i + span]):
                    # keep the SECOND (usually cleaner) take; cut the first.
                    for j in range(i, i + span):
                        reason[j] = f"repeated take (kept the later, cleaner {span}-word take)"
                    i += span
                else:
                    i += 1
    return reason


def build_segments(words, reason, gap_ms):
    """Collapse kept words into contiguous kept segments and record cuts.

    Returns (keep_segments, cuts) where a keep segment is
    {start_ms,end_ms,text} and a cut is {start_ms,end_ms,text,reason}."""
    keep = []
    cuts = []
    cur = None
    for i, w in enumerate(words):
        r = reason[i]
        if r is None:
            if cur is None:
                cur = {"start": w["start"], "end": w["end"], "text": [w["text"]]}
            else:
                # dead air between kept words counts as a cut if it exceeds gap.
                if w["start"] - cur["end"] > gap_ms:
                    keep.append(cur)
                    cuts.append({"start": cur["end"], "end": w["start"],
                                 "text": "(silence)", "reason": "dead air"})
                    cur = {"start": w["start"], "end": w["end"], "text": [w["text"]]}
                else:
                    cur["end"] = w["end"]
                    cur["text"].append(w["text"])
        else:
            if cur is not None:
                keep.append(cur)
                cur = None
            # merge consecutive removed words sharing a reason into one cut.
            if cuts and cuts[-1]["end"] >= w["start"] - 1 and cuts[-1]["reason"] == r:
                cuts[-1]["end"] = w["end"]
                cuts[-1]["text"] += " " + w["text"]
            else:
                cuts.append({"start": w["start"], "end": w["end"],
                             "text": w["text"], "reason": r})
    if cur is not None:
        keep.append(cur)
    for k in keep:
        k["text"] = " ".join(k["text"])
    return keep, cuts


def apply_handles(keep, handle_ms, total_ms):
    """Extend each kept segment by handle_ms at head/tail, clamped to neighbours
    and the media bounds, so cuts are not frame-tight."""
    out = []
    for idx, k in enumerate(keep):
        s = k["start"] - handle_ms
        e = k["end"] + handle_ms
        prev_end = keep[idx - 1]["end"] if idx > 0 else 0
        next_start = keep[idx + 1]["start"] if idx + 1 < len(keep) else total_ms
        s = max(s, 0, (prev_end + k["start"]) // 2 if idx > 0 else 0)
        e = min(e, total_ms, (next_start + k["end"]) // 2 if idx + 1 < len(keep) else total_ms)
        if e <= s:
            e = s + 1
        out.append({"start": s, "end": e, "text": k["text"]})
    return out


def tc(ms, fps):
    """Milliseconds -> HH:MM:SS:FF timecode. Frames are counted against the
    nearest whole frame rate (non-drop), which is what EDL/FCPXML expect."""
    base = int(round(fps))
    total_frames = round(ms / 1000.0 * fps)
    f = total_frames % base
    total_seconds = total_frames // base
    s = total_seconds % 60
    m = (total_seconds // 60) % 60
    h = total_seconds // 3600
    return f"{h:02d}:{m:02d}:{s:02d}:{int(f):02d}"


def write_paper_edit(out, keep, cuts, words, fps, aggression, clip_name):
    src_total = words[-1]["end"] - words[0]["start"]
    kept_total = sum(k["end"] - k["start"] for k in keep)
    lines = []
    lines.append(f"# Paper edit — {clip_name}\n")
    lines.append("Review this BEFORE the timeline. Mark any cut you disagree with by "
                 "writing `KEEP` on its line, then ask for a regenerate.\n")
    lines.append(f"- Aggression: {aggression}")
    lines.append(f"- Source runtime: {tc(src_total, fps)} ({src_total/1000:.1f}s)")
    lines.append(f"- Edited runtime: {tc(kept_total, fps)} ({kept_total/1000:.1f}s)")
    lines.append(f"- Removed: {(src_total - kept_total)/1000:.1f}s across {len(cuts)} cuts\n")
    lines.append("## Cuts\n")
    if not cuts:
        lines.append("_No cuts proposed — the take is already clean._\n")
    for i, c in enumerate(cuts, 1):
        txt = c["text"].strip()
        if len(txt) > 120:
            txt = txt[:117] + "..."
        lines.append(f"{i}. `{tc(c['start'], fps)}`–`{tc(c['end'], fps)}` — "
                     f"{c['reason']} — removed: \"{txt}\"")
    lines.append("\n## Kept segments (the rough cut, in order)\n")
    for i, k in enumerate(keep, 1):
        txt = k["text"].strip()
        if len(txt) > 140:
            txt = txt[:137] + "..."
        lines.append(f"{i}. `{tc(k['start'], fps)}`–`{tc(k['end'], fps)}` — \"{txt}\"")
    with open(out, "w") as fh:
        fh.write("\n".join(lines) + "\n")


def write_edl(out, keep, fps, reel, title):
    lines = [f"TITLE: {title}", "FCM: NON-DROP FRAME", ""]
    rec = 0
    for i, k in enumerate(keep, 1):
        dur = k["end"] - k["start"]
        src_in, src_out = k["start"], k["end"]
        rec_in, rec_out = rec, rec + dur
        rec = rec_out
        lines.append(
            f"{i:03d}  {reel:<8} AA/V  C        "
            f"{tc(src_in, fps)} {tc(src_out, fps)} {tc(rec_in, fps)} {tc(rec_out, fps)}")
        lines.append(f"* FROM CLIP NAME: {title}")
        lines.append("")
    with open(out, "w") as fh:
        fh.write("\n".join(lines) + "\n")


def write_fcpxml(out, keep, fps, clip_name, src_file):
    # FCPXML 1.13 (Final Cut Pro 11). Single asset, one spine of asset-clips that
    # carry sync audio+video. Durations are rational "<frames>/<fps>s".
    ifps = int(round(fps))

    def rt(ms):
        return f"{round(ms / 1000.0 * fps)}/{ifps}s"
    total_ms = sum(k["end"] - k["start"] for k in keep)
    fmt_dur = rt(max((w := [k["end"] for k in keep]) and max(w) or 0, total_ms))
    src_uri = "file://" + escape(os.path.abspath(src_file))
    body = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<!DOCTYPE fcpxml>',
        '<fcpxml version="1.13">',
        '  <resources>',
        f'    <format id="r1" name="FFVideoFormat1080p{ifps}" frameDuration="1/{ifps}s" width="1920" height="1080"/>',
        f'    <asset id="a1" name="{escape(clip_name)}" start="0s" hasVideo="1" hasAudio="1" format="r1" duration="{fmt_dur}">',
        f'      <media-rep kind="original-media" src="{src_uri}"/>',
        '    </asset>',
        '  </resources>',
        '  <library>',
        f'    <event name="radio-edit">',
        f'      <project name="{escape(clip_name)} (rough cut)">',
        f'        <sequence format="r1" tcStart="0s" tcFormat="NDF">',
        '          <spine>',
    ]
    offset = 0
    for idx, k in enumerate(keep):
        dur = k["end"] - k["start"]
        body.append(
            f'            <asset-clip ref="a1" offset="{rt(offset)}" '
            f'name="{escape(clip_name)}" start="{rt(k["start"])}" '
            f'duration="{rt(dur)}" format="r1" tcFormat="NDF"/>')
        offset += dur
    body += [
        '          </spine>',
        '        </sequence>',
        '      </project>',
        '    </event>',
        '  </library>',
        '</fcpxml>',
    ]
    with open(out, "w") as fh:
        fh.write("\n".join(body) + "\n")


def cmd_selftest():
    """Offline checks of the pure edit logic — no media, no transcript needed."""
    # timecode: ms -> HH:MM:SS:FF at the given fps
    assert tc(0, 30) == "00:00:00:00", tc(0, 30)
    assert tc(1000, 30) == "00:00:01:00", tc(1000, 30)
    assert tc(3661000, 30) == "01:01:01:00", tc(3661000, 30)

    # token normalization strips punctuation and lowercases, keeps apostrophes
    assert norm("Um,") == "um", norm("Um,")
    assert norm("I'll") == "i'll", norm("I'll")

    # filler + stutter removal, then segment building
    words = [
        {"text": "So",   "start": 0,   "end": 200},
        {"text": "um",   "start": 250, "end": 400},   # filler -> cut
        {"text": "the",  "start": 450, "end": 600},   # first of a stutter -> cut
        {"text": "the",  "start": 620, "end": 750},
        {"text": "plan", "start": 800, "end": 1000},
    ]
    preset = dict(PRESETS["balanced"])
    reason = mark_removals(words, preset, [])
    assert reason[1] == "filler", reason
    assert reason[2] and reason[2].startswith("stutter"), reason
    keep, cuts = build_segments(words, reason, preset["gap_ms"])
    assert len(keep) == 2, keep
    assert len(cuts) == 2, cuts
    assert keep[1]["text"] == "the plan", keep[1]

    # handles extend a segment but clamp to the media bounds
    handled = apply_handles([{"start": 100, "end": 200, "text": "x"}], 1000, 5000)
    assert handled[0]["start"] == 0 and handled[0]["end"] == 1200, handled

    print("selftest OK: timecode, normalization, removal, segments, and handles are correct.")


def main():
    if len(sys.argv) == 2 and sys.argv[1] == "selftest":
        cmd_selftest()
        return
    ap = argparse.ArgumentParser(description="Transcript-driven rough cut.")
    ap.add_argument("source")
    ap.add_argument("--fps", type=float, default=30.0)
    ap.add_argument("--aggression", choices=list(PRESETS), default="balanced")
    ap.add_argument("--handles", type=int, default=6, help="frames of handle per cut")
    ap.add_argument("--gap-ms", type=int, default=None)
    ap.add_argument("--always-cut", default=None)
    ap.add_argument("--reel", default="AX")
    ap.add_argument("--format", choices=["edl", "fcpxml"], default="edl")
    ap.add_argument("--out", default=None)
    args = ap.parse_args()

    fps = args.fps
    preset = dict(PRESETS[args.aggression])
    if args.gap_ms is not None:
        preset["gap_ms"] = args.gap_ms

    always_cut = []
    if args.always_cut:
        if not os.path.isfile(args.always_cut):
            fail(f"--always-cut file not found: {args.always_cut}")
        with open(args.always_cut) as fh:
            for line in fh:
                line = line.strip()
                if line:
                    always_cut.append([norm(t) for t in line.split()])

    words_path = find_words_json(args.source)
    words = load_words(words_path)

    # derive a clip name + source media path from the transcript folder location.
    tdir = os.path.dirname(os.path.abspath(words_path))
    clip_name = os.path.basename(tdir).replace(".transcript", "") or "clip"
    src_guess = tdir.replace(".transcript", "")
    src_file = args.source if os.path.isfile(args.source) and not args.source.endswith(".json") else src_guess

    out_dir = args.out or (src_guess + ".radioedit")
    os.makedirs(out_dir, exist_ok=True)

    reason = mark_removals(words, preset, always_cut)
    keep, cuts = build_segments(words, reason, preset["gap_ms"])
    if not keep:
        fail("every word was marked for removal — loosen --aggression or check the transcript.")
    total_ms = words[-1]["end"]
    handle_ms = int(args.handles / fps * 1000)
    keep = apply_handles(keep, handle_ms, total_ms)

    paper = os.path.join(out_dir, "paper-edit.md")
    write_paper_edit(paper, keep, cuts, words, fps, args.aggression, clip_name)

    if args.format == "edl":
        tl = os.path.join(out_dir, "edit.edl")
        write_edl(tl, keep, fps, args.reel, clip_name)
    else:
        tl = os.path.join(out_dir, "edit.fcpxml")
        write_fcpxml(tl, keep, fps, clip_name, src_file)

    print(f"paper edit: {paper}")
    print(f"timeline:   {tl}")
    print(f"cuts: {len(cuts)}   kept segments: {len(keep)}   "
          f"runtime: {sum(k['end']-k['start'] for k in keep)/1000:.1f}s "
          f"(was {(words[-1]['end']-words[0]['start'])/1000:.1f}s)")


if __name__ == "__main__":
    main()
