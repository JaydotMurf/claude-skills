# Runbooks

Compositions: each runbook chains existing skills into one repeatable outcome. A skill answers what an agent can do; a runbook answers what the system can reliably produce.

Each runbook lives in its own folder as `runbooks/<runbook-name>/RUNBOOK.md`, built from the template in `templates/RUNBOOK-TEMPLATE.md`. Runbooks are generated after the skills they call exist, because a runbook may only name skills already in the library.

The 7 runbooks:

- [talk-to-published](talk-to-published/RUNBOOK.md) — a voice memo becomes a published page.
- [release-day](release-day/RUNBOOK.md) — an accurate, on-brand briefing published the same day something ships.
- [video-production-line](video-production-line/RUNBOOK.md) — raw footage becomes a finished, graphics-laden edit with the editorial work front-loaded.
- [ship-a-page-you-can-trust](ship-a-page-you-can-trust/RUNBOOK.md) — a page shipped with verified quality and a banked regression test.
- [research-engine](research-engine/RUNBOOK.md) — research with a chain of custody, every claim traceable and every conclusion stress-tested.
- [delegate-and-verify](delegate-and-verify/RUNBOOK.md) — parallel engineering lanes where you touch only what done means and whether the diff is good.
- [flywheel](flywheel/RUNBOOK.md) — the posture under every other runbook, so no useful discovery dies in chat.

The build prompt behind each runbook lives in `meta-prompts/runbooks/`.
