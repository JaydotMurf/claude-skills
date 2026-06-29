#!/usr/bin/env python3
# nle-assistant: drive DaVinci Resolve through its Python scripting API to do
# transcript-driven editing inside a real project — verify a connection, duplicate
# a timeline (the safety copy), and remove silences by rebuilding the kept ranges
# of a clip on a NEW timeline.
#
# External scripting requires DaVinci Resolve STUDIO with a project open. The free
# version only scripts from its internal console. No API key, no network.
#
# Subcommands:
#   nle.py connect
#       Verify the connection and print project / timeline state. Run this first.
#   nle.py duplicate [--name NAME]
#       Duplicate the current timeline (the safety copy). Never edits the original.
#   nle.py silence-removal --clip NAME --transcript DIR [--gap-ms 700] [--fps 30]
#       Duplicate the current timeline for safety, compute kept (non-silence)
#       ranges from the media-transcription words.json, and build a new timeline
#       containing only those ranges of the named clip.
#   nle.py selftest
#       Offline check of the transcript -> kept-frame-range math. No Resolve needed.
#
# Failure modes are explicit: app not running, project not open, clip not found.

import argparse
import json
import os
import sys


# --- connection -------------------------------------------------------------

def get_resolve():
    """Return the Resolve app object, or None if it cannot be reached.

    Imports the DaVinciResolveScript module that ships with the app, falling back
    to the default per-OS module path when it is not already on PYTHONPATH."""
    try:
        import DaVinciResolveScript as bmd  # noqa: N813
    except ImportError:
        if sys.platform.startswith("darwin"):
            mod = ("/Library/Application Support/Blackmagic Design/"
                   "DaVinci Resolve/Developer/Scripting/Modules/")
        elif sys.platform.startswith("win"):
            mod = os.path.join(os.environ.get("PROGRAMDATA", r"C:\ProgramData"),
                               r"Blackmagic Design",
                               r"DaVinci Resolve\Support\Developer\Scripting\Modules")
        else:
            mod = "/opt/resolve/Developer/Scripting/Modules/"
        sys.path.append(mod)
        try:
            import DaVinciResolveScript as bmd  # noqa: N813
        except ImportError:
            return None
    return bmd.scriptapp("Resolve")


def connect_or_die():
    """Return (resolve, project) or exit with a clear, actionable message."""
    resolve = get_resolve()
    if resolve is None:
        die("cannot reach DaVinci Resolve. Is the app running? External scripting "
            "needs DaVinci Resolve STUDIO (the free version scripts only from its "
            "internal console). Confirm the app is open, then retry.")
    pm = resolve.GetProjectManager()
    project = pm.GetCurrentProject() if pm else None
    if project is None:
        die("connected to Resolve, but no project is open. Open a project in the "
            "app, then retry.")
    return resolve, project


def current_timeline_or_die(project):
    tl = project.GetCurrentTimeline()
    if tl is None:
        die("a project is open but it has no current timeline. Open or create a "
            "timeline in the app, then retry.")
    return tl


def die(msg):
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


# --- transcript math (pure, offline-testable) -------------------------------

def kept_ranges_ms(words, gap_ms):
    """From an AssemblyAI word array (start/end in ms), return [(start,end), ...]
    contiguous spoken ranges, splitting wherever a silent gap exceeds gap_ms."""
    if not words:
        return []
    ranges = []
    cur_start = words[0]["start"]
    cur_end = words[0]["end"]
    for w in words[1:]:
        if w["start"] - cur_end > gap_ms:
            ranges.append((cur_start, cur_end))
            cur_start = w["start"]
        cur_end = w["end"]
    ranges.append((cur_start, cur_end))
    return ranges


def ms_to_frame(ms, fps):
    return int(round(ms / 1000.0 * fps))


def load_words(transcript_dir):
    wp = os.path.join(transcript_dir, "words.json")
    if not os.path.isfile(wp):
        die(f"no words.json in {transcript_dir}. Run media-transcription first.")
    with open(wp) as fh:
        data = json.load(fh)
    words = data.get("words", data) if isinstance(data, dict) else data
    if not isinstance(words, list) or not words:
        die(f"{wp} holds no words.")
    return [{"start": int(w["start"]), "end": int(w["end"])} for w in words]


# --- media pool helpers -----------------------------------------------------

def find_clip(project, name):
    """Search the media pool (root + sub-folders) for a clip by name."""
    mp = project.GetMediaPool()
    root = mp.GetRootFolder()
    stack = [root]
    while stack:
        folder = stack.pop()
        for item in folder.GetClipList() or []:
            if item.GetName() == name:
                return mp, item
        stack.extend(folder.GetSubFolderList() or [])
    return mp, None


# --- subcommands ------------------------------------------------------------

def cmd_connect(_args):
    resolve, project = connect_or_die()
    name = project.GetName()
    tl_count = project.GetTimelineCount()
    cur = project.GetCurrentTimeline()
    print(f"connected. Resolve {resolve.GetVersionString()}")
    print(f"project: {name}")
    print(f"timelines: {tl_count}")
    print(f"current timeline: {cur.GetName() if cur else '(none)'}")


def cmd_duplicate(args):
    _resolve, project = connect_or_die()
    tl = current_timeline_or_die(project)
    new_name = args.name or (tl.GetName() + " — working copy")
    dup = tl.DuplicateTimeline(new_name)
    if dup is None:
        die("DuplicateTimeline failed; nothing was changed.")
    print(f"duplicated '{tl.GetName()}' -> '{dup.GetName()}'. Edit the copy only.")


def cmd_silence_removal(args):
    _resolve, project = connect_or_die()
    original = current_timeline_or_die(project)

    # SAFETY: duplicate first. The original is never touched.
    safe_name = original.GetName() + " — working copy"
    working = original.DuplicateTimeline(safe_name)
    if working is None:
        die("could not duplicate the timeline; aborting before any edit.")
    print(f"safety copy made: '{working.GetName()}'. Original is untouched.")

    mp, clip = find_clip(project, args.clip)
    if clip is None:
        die(f"clip '{args.clip}' not found in the media pool.")

    words = load_words(args.transcript)
    ranges = kept_ranges_ms(words, args.gap_ms)
    if not ranges:
        die("no spoken ranges found; check the transcript.")

    # Build a new timeline with only the kept frame ranges of the clip.
    sub_items = [
        {"mediaPoolItem": clip,
         "startFrame": ms_to_frame(s, args.fps),
         "endFrame": ms_to_frame(e, args.fps)}
        for (s, e) in ranges
    ]
    out_name = f"{args.clip} — silences removed"
    new_tl = mp.CreateEmptyTimeline(out_name)
    if new_tl is None:
        die("could not create the output timeline.")
    project.SetCurrentTimeline(new_tl)
    appended = mp.AppendToTimeline(sub_items)
    if not appended:
        die("AppendToTimeline returned nothing; the ranges may be invalid.")
    kept_ms = sum(e - s for s, e in ranges)
    span_ms = words[-1]["end"] - words[0]["start"]
    print(f"built '{out_name}': {len(ranges)} spoken ranges, "
          f"{kept_ms/1000:.1f}s kept of {span_ms/1000:.1f}s "
          f"({(span_ms-kept_ms)/1000:.1f}s of silence removed).")
    print("Review it in the app before doing anything to the real project.")


def cmd_selftest(_args):
    # Verify the pure transcript math without Resolve.
    words = [
        {"start": 0, "end": 500},
        {"start": 600, "end": 1000},     # 100ms gap -> same range
        {"start": 3000, "end": 3500},    # 2000ms gap -> new range
        {"start": 3600, "end": 4000},
    ]
    ranges = kept_ranges_ms(words, 700)
    assert ranges == [(0, 1000), (3000, 4000)], ranges
    assert ms_to_frame(1000, 30) == 30, ms_to_frame(1000, 30)
    assert kept_ranges_ms([], 700) == []
    print("selftest OK: kept-range and frame math correct.")


def main():
    ap = argparse.ArgumentParser(description="Drive DaVinci Resolve for transcript-driven edits.")
    sub = ap.add_subparsers(dest="cmd", required=True)

    sub.add_parser("connect")

    d = sub.add_parser("duplicate")
    d.add_argument("--name", default=None)

    s = sub.add_parser("silence-removal")
    s.add_argument("--clip", required=True)
    s.add_argument("--transcript", required=True, help="path to <media>.transcript/ folder")
    s.add_argument("--gap-ms", type=int, default=700)
    s.add_argument("--fps", type=float, default=30.0)

    sub.add_parser("selftest")

    args = ap.parse_args()
    {
        "connect": cmd_connect,
        "duplicate": cmd_duplicate,
        "silence-removal": cmd_silence_removal,
        "selftest": cmd_selftest,
    }[args.cmd](args)


if __name__ == "__main__":
    main()
