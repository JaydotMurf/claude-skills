# Verification ledger

Tier 3 of the quality-test system: dated evidence from real, paid, or
hardware-dependent runs that the deterministic gate and the behavioral evals
cannot produce. Each row records when a skill was last validated against its real
external dependency, what it cost, and what shape it returned. The per-`SKILL.md`
Verification standard holds the detail; this table is the at-a-glance index.

Status: `live` = validated against the real API/hardware; `static` = syntax,
schema, and no-key/arg behavior verified, live run still deferred.

## Paid API paths

| Skill | Status | Last validated | Cost | Evidence |
|---|---|---|---|---|
| current-info-search | live | 2026-07-01 | $0.00525 / query | Dated, sourced answer via Perplexity `/chat/completions`; fixed a broken `/v1/sonar` endpoint and added real cost output. |
| media-transcription | live | 2026-07-01 | < $0.01 (25s clip) | Four-artifact package, 65 words, one auto-chapter, all non-empty. |
| image-gateway | live | 2026-07-01 | $0.0388 (default) | 1024x1024 PNG on `google/gemini-2.5-flash-image`; `IMAGE_GATEWAY_MODEL` override proven live at $0.13616 on `google/gemini-3-pro-image`. |
| image-model-arena | live | 2026-07-01 | $0.175 (2 imgs) | Two-model composer run; per-image cost recorded to `registry.json`. |
| essay-illustration-gallery | live | 2026-07-01 | $0.077 (2 frames) | Self-contained gallery HTML, base64 images, zero external references. |
| stakeholder-update-email | live | 2026-07-01 | $0 (Resend free tier) | Sandbox send returned message id `bf82e792-…`; added `--reply-to`. |

Paid validation pass total: about $0.44.

## Hardware and render paths (deferred)

| Skill | Status | Blocker |
|---|---|---|
| radio-edit | static | EDL/FCPXML import into a real NLE; pure edit logic covered by `radio-edit.py selftest`. |
| broll-pipeline | static | End-to-end Remotion render + ffmpeg composite; needs the Remotion toolchain. |
| nle-assistant | static | DaVinci Resolve round-trip; frame/range math covered by `nle.py selftest`. |

## How to add a row

Run the skill against its real dependency, record cost and output shape in the
skill's Verification standard with the date, then add or update its row here.
Keep this table and the per-skill notes in sync.
