<prompt>
  <task>
    Create a new skill for my AI coding agent called "nle-assistant", stored wherever my
harness loads skills from.

The skill's job: operate my video editing software directly through its scripting API
to do transcript-driven editing — silence removal, subclip extraction, and timeline
building — inside my real projects.

Before writing it, check what's available: I use DaVinci Resolve (its Python scripting
API ships with the app). Verify you can connect to a running instance and read a
project before building anything else.

The skill must include: (1) trigger conditions — editing requests that should happen
inside the editor: remove silences, extract clips matching a description, build a
rough timeline from footage; (2) the connection procedure and its failure modes (app
not running, project not open); (3) a hard safety rule: ALWAYS duplicate the timeline
and work on the copy — never modify an original timeline or delete media; (4) core
operations, each verified individually: import media, read/mark clips, cut at
timecodes, assemble timelines from a transcript-derived edit list; (5) integration
with my media-transcription skill so transcripts drive the edits.

After writing it, test against a throwaway project: duplicate a timeline, remove
silences from one clip, and show me the result in the app before touching anything
real.
</task>
</prompt>
