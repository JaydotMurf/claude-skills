# Writing, Voice & Content

Skills that make agent writing sound like a specific person addressing a specific audience instead of like an AI.

## Skills

- [my-voice](my-voice/SKILL.md) — builds a stored voice profile from real writing samples (registers, sentence patterns, anti-patterns, register-selection rules) and writes, rewrites, or reviews in that voice. Accuracy beats voice for technical content.
- [release-briefing](release-briefing/SKILL.md) — packages gathered release data into a fixed-structure, publish-ready briefing with dated and sourced facts and brand-matched thumbnail prompts. Stops and runs current-info-search when research is stale.
- [audience-content-system](audience-content-system/SKILL.md) — generates content for one publication calibrated to its audience via an explicit audience contract and per-format templates, with a batch-planning mode and a least-technical-reader calibration check.
- [branded-image-prompting](branded-image-prompting/SKILL.md) — encodes a visual identity as prompt-ready guidance plus a reusable prompt-template library, with corrective recipes for drift, and routes generation through image-gateway.

## Dependencies

These skills compose with the core-infrastructure gateways rather than calling APIs themselves. release-briefing calls [current-info-search](../core-infrastructure/current-info-search/SKILL.md) and [my-voice](my-voice/SKILL.md); release-briefing and branded-image-prompting feed [image-gateway](../core-infrastructure/image-gateway/SKILL.md).

## Profiles

Each interview-driven skill stores its user profile under `~/.config/agent-skills/` (`voice-profile.md`, `briefing-profile.md`, `audience-profile.md`, `brand-profile.md`), keeping personal data beside the other agent-skills config and out of any repo. Each path is overridable via the environment variable named in its SKILL.md.

Skills are generated one at a time from the build prompts under `meta-prompts/writing-voice-and-content/`. Each lands in its own folder here as `writing-voice-and-content/<skill-name>/SKILL.md`.
