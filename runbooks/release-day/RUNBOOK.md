---
name: release-day
description: Publish an accurate, on-brand briefing the same day something ships in your field, with primary-source facts and a matching branded thumbnail, then notify your list.
tags: [publishing, research, briefing, images]
audience: engineers, solo operators, and analysts
---

# Release Day

Something big ships in your field at 10am and you want an accurate, on-brand briefing live by noon. This runbook front-loads the fact-gathering that keeps stale model memory out of the page, then packages, illustrates, publishes, and announces it.

## Outcome

A same-day briefing published at a live URL, written from dated primary-source facts in your standard format, fronted by a branded thumbnail, with a stakeholder update sent telling your list or team it is live.

## Skills it calls

1. `core-infrastructure/current-info-search` — takes the release subject; produces an answer grounded in live search with a Sources list of title, URL, and publication date for each fact. Hands the dated, sourced facts to the next step.
2. `writing-voice-and-content/release-briefing` — takes the dated facts; produces a briefing package in fixed order (title, subtitle, what changed, why it matters, what to do about it) plus 2–3 thumbnail prompts matched to the subject's brand colors. Hands the chosen thumbnail prompt to the next step and the briefing prose forward.
3. `writing-voice-and-content/branded-image-prompting` — takes the thumbnail prompt; wraps it in the brand guidance block from a named library template. Hands the brand-ready image prompt to the next step.
4. `core-infrastructure/image-gateway` — takes the brand-ready prompt; produces a single PNG with its saved path and per-image cost. Hands the thumbnail image path to the next step.
5. `web-publishing-and-frontend/site-publisher` — takes the briefing prose and the thumbnail; ships them to a live URL with a clean slug, OG image, and share metadata. Hands the live URL to the next step.
6. `agent-operations/stakeholder-update-email` — takes the live URL and the briefing's verified outcomes; drafts a what-changed / what-it-means / what's-next update and, on explicit confirmation, sends it via Resend with you CC'd.

## Verification

- Every fact in the briefing traces to a Sources entry with a URL and a publication date; unverified items are labeled as such.
- The thumbnail PNG exists at its reported path, and its cost is recorded.
- The live URL resolves and the link preview renders the branded thumbnail.
- The update email is sent only after explicit confirmation, claims only verified outcomes, and returns a message id (or is held as a draft).
