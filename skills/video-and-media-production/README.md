# Video & Media Production

The most complicated skills in the library, and the most dramatic demonstrations of what agent skills can do. All three are transcript-driven: they consume the package from [media-transcription](../core-infrastructure/media-transcription/SKILL.md) and never call a transcription API themselves.

## Skills

- [radio-edit](radio-edit/SKILL.md) — transcript-driven rough cut of talking-head footage. Detects filler, stutters, repeated takes (keeps the later, cleaner one), dead air, and always-cut phrases, writes a paper edit for review FIRST, then exports a timeline (CMX3600 EDL by default, FCPXML 1.13 optional) with a frame handle on each cut. Local-only.
- [broll-pipeline](broll-pipeline/SKILL.md) — end-to-end motion-graphics pipeline. A SCOUT subagent picks moments and writes a manifest, a BUILDER subagent generates Remotion graphics against one shared visual contract, and the orchestrator renders each to a transparent ProRes clip and composites them onto the video with ffmpeg, tracking state so a long run resumes after interruption.
- [nle-assistant](nle-assistant/SKILL.md) — operate DaVinci Resolve through its Python scripting API for transcript-driven editing inside a real project: connect, duplicate the timeline as a safety copy, and remove silences by rebuilding the spoken ranges on a new timeline. Never edits an original.

## How they compose

All three sit downstream of [media-transcription](../core-infrastructure/media-transcription/SKILL.md): radio-edit and nle-assistant read its `words.json` to drive cuts; broll-pipeline's SCOUT reads its chaptered transcript to place graphics. radio-edit comes first in a typical flow (lock the spoken edit), then broll-pipeline adds overlays to the cut, while nle-assistant is the alternative when the work should happen inside the user's Resolve project rather than as portable files.

The build prompts that generated each skill live under [meta-prompts/video-and-media-production/](../../meta-prompts/video-and-media-production/).
