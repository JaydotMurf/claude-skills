# Issue tracker: Local Markdown

Issues and PRDs for this repo live as markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The PRD is `.scratch/<feature-slug>/PRD.md`
- Implementation issues are `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`
- Triage state is recorded as a `Status:` line near the top of each issue file (see `triage-labels.md` for the role strings)
- Comments and conversation history append to the bottom of the file under a `## Comments` heading

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<feature-slug>/` (creating the directory if needed).

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.

## Wayfinding operations

Used by `/wayfinder`. The map is a file with one child file per ticket, under the same `.scratch/<effort>/` directory this tracker already uses for features.

- **Map**: `.scratch/<effort>/map.md` — the Destination / Notes / Decisions-so-far / Not-yet-specified / Out-of-scope body. This is the `wayfinder:map` artifact; the local tracker has no labels, so the filename `map.md` is the marker.
- **Child ticket**: `.scratch/<effort>/issues/<NN>-<slug>.md`, numbered from `01`, with the question in the body. A `Type:` line records the ticket type (`research`/`prototype`/`grilling`/`task`); a `Status:` line records `claimed`/`resolved` (an absent `Status:` means open and unclaimed).
- **Blocking**: a `Blocked by: <NN>, <NN>` line near the top, listing blocker file numbers. A ticket is unblocked when every file it lists is `Status: resolved`.
- **Frontier query**: scan `.scratch/<effort>/issues/` for files that are open (no `resolved` status), unblocked (every `Blocked by` entry resolved), and unclaimed (no `claimed` status); first by number wins.
- **Claim**: set `Status: claimed` and save before any work — the session's first write.
- **Resolve**: append the answer under an `## Answer` heading, set `Status: resolved`, then append a context pointer (gist + link to the file) to the map's Decisions-so-far in `map.md`.
