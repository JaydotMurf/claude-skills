# Web Publishing & Frontend

Skills that take agent output public, with taste, verification, and a repeatable shipping procedure.

## Skills

- [frontend-taste](frontend-taste/SKILL.md) — a taste system that overrides default frontend instincts for all UI work, with hard layout/typography/color rules, a mandatory visual verification loop, and four nested sub-skills ([minimalist-editorial](frontend-taste/minimalist-editorial/SKILL.md), [data-dense-dashboard](frontend-taste/data-dense-dashboard/SKILL.md), [premium-marketing](frontend-taste/premium-marketing/SKILL.md), [redesign-existing](frontend-taste/redesign-existing/SKILL.md)) routed by task type.
- [site-publisher](site-publisher/SKILL.md) — publish a finished page or artifact to the user's own site as a real shareable URL: clean slug, page matching site conventions, 1200x630 Open Graph image, share metadata, indexing controls, local verification, deploy, and post-publish checks. Triggers only on an explicit publish request. Composes image-gateway.
- [image-model-arena](image-model-arena/SKILL.md) — build and publish image-model comparison pages from a single config: a per-model review page plus a shared side-by-side viewer, with a registry tracking per-image cost and content-policy quirks. Composes image-gateway and site-publisher.
- [essay-illustration-gallery](essay-illustration-gallery/SKILL.md) — turn a finished essay into a consistent illustration gallery: moments across the full arc, one locked style, per-frame captions, and a single self-contained gallery page. Composes image-gateway and site-publisher.

## How they compose

site-publisher and frontend-taste are the foundation here. image-model-arena and essay-illustration-gallery both compose [image-gateway](../core-infrastructure/image-gateway/SKILL.md) for generation and site-publisher for publishing, and never reimplement either. essay-illustration-gallery also assembles its page to the [html-artifacts](../core-infrastructure/html-artifacts/SKILL.md) single-self-contained-file convention.

The build prompts that generated each skill live under [meta-prompts/web-publishing-and-frontend/](../../meta-prompts/web-publishing-and-frontend/).
