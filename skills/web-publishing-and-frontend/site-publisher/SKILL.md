---
name: site-publisher
description: Publish a finished page or artifact to the user's own website as a real shareable URL, end to end — clean slug, a page matching site conventions, a 1200x630 Open Graph image via image-gateway, share metadata, indexing controls, local verification, deploy, and post-publish checks. Trigger ONLY when the user explicitly asks to publish, ship, or put something on the site. Other skills that need to take output live call this instead of writing their own deploy steps.
tags: [publishing, deploy, open-graph, web-publishing-and-frontend]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Site Publisher

Takes a finished page or artifact and puts it on the user's website as a real, shareable URL: slug, page, Open Graph image, share metadata, indexing control, local check, deploy, and a live confirmation. It composes image-gateway for the OG image and never reimplements image generation.

## When to use this skill

Invoke it ONLY when the user explicitly asks to publish, ship, put live, or put on the site a specific page or artifact. Examples: "publish this", "ship this to the site", "put this up as a share link".

Never auto-trigger it. Producing a page, an artifact, or a draft is not a request to publish it. If the user has not used a publish/ship/put-live verb about this specific thing, do not run this skill. When in doubt, ask before publishing; do not assume.

## Site configuration

This skill is site-specific, so it reads its settings from a config file rather than hard-coding any one site. Default location `~/.config/agent-skills/site-publisher.json`:

```json
{
  "repo_path": "~/sites/my-site",
  "stack": "next-app-router",
  "pages_dir": "app",
  "route_convention": "app/<slug>/page.tsx",
  "deploy_command": "vercel --prod",
  "verify_command": "npm run build && npm run start",
  "local_url": "http://localhost:3000",
  "design_reference": "app/blog/[slug]/page.tsx",
  "default_indexing": "unlisted",
  "base_url": "https://example.com"
}
```

On the first run, if the config is missing, interview the user for each field (repo path and stack, how routes/pages are added, the deploy command and any verify steps, the design language or which existing page to match, and the default indexing preference for one-off share pages), explore the repo to confirm the answers, then write the config and proceed. The config is read every run; the interview happens once.

Recorded assumption (build time): no website repo was available to explore at build time, so the defaults above are placeholders for a Next.js App Router site deployed on Vercel, and `default_indexing` is set to `unlisted` — the safer choice for one-off share pages. Confirm and overwrite these on first real use.

## Steps

### Step 1 — Confirm the explicit publish request and load config

Confirm the user asked to publish this specific page or artifact. Read the site config (or run the first-run interview to create it). Completion: an explicit publish request and a loaded config.

### Step 2 — Make a clean slug

Derive a slug from the title: lowercase, hyphen-separated, alphanumeric only, no stop-word noise, short. Check it does not collide with an existing route in `pages_dir`; if it does, disambiguate rather than overwrite. Completion: a unique, clean slug.

### Step 3 — Create the page matching site conventions

Create the route at the path the config's `route_convention` dictates, matching the `design_reference` page's structure, layout, and house style. Bring the finished content in; do not redesign it. Completion: a page file exists at the right route and matches site conventions.

### Step 4 — Generate the 1200x630 Open Graph image

Produce a page-specific OG image through image-gateway, then size it to exactly 1200x630:

```bash
./make-og-image.sh "a clean editorial cover image for: <page title>" --out og-<slug>.png
```

`make-og-image.sh` calls image-gateway to generate the image and crops it to exactly 1200x630. Place the result where the site serves static share images and reference it from the page. Never hand-roll an image API call here; route it through image-gateway. Completion: a 1200x630 PNG exists and is referenced by the page.

### Step 5 — Set share metadata and indexing

Set the share title and description (Open Graph and Twitter tags) and point the OG image tag at the file from Step 4. Apply the indexing control: for `unlisted`, add `<meta name="robots" content="noindex">` and keep the page out of sitemaps and link lists; for `public`, allow indexing and add it to the sitemap. Honor the config's `default_indexing` unless the user overrides it for this page. Completion: share metadata and the correct robots directive are set.

### Step 6 — Verify locally before deploying

Run the config's `verify_command`, open the page at `local_url`, and confirm it renders correctly: content, layout, OG tags present, OG image loads, robots directive correct. Do not deploy until the local page is right. Completion: the page built and rendered correctly locally.

### Step 7 — Deploy

Run the config's `deploy_command` and capture the resulting live URL. Completion: the deploy succeeded and a live URL is in hand.

### Step 8 — Post-publish checks

Fetch the live URL and confirm it returns 200 and renders. Confirm the OG preview is correct: the `og:image`, `og:title`, and `og:description` resolve and the image is the 1200x630 file. Confirm the robots directive matches the chosen indexing. Report the live URL and the indexing state. Completion: the live page loads and its share preview renders correctly.

## For other skills

If your skill needs to take a finished page or artifact live, call site-publisher rather than writing your own deploy steps. It owns slug, page creation, OG image, metadata, indexing, deploy, and post-publish verification in one place.

## Guardrails

- Never publish without an explicit publish/ship/put-live request from the user about this specific page; this skill is never auto-triggered.
- Never deploy before the local verification in Step 6 passes; an unbuilt or unviewed page does not go live.
- Never generate the OG image with a direct image API call; route it through image-gateway.
- Never default a one-off share page to public indexing; honor the configured `default_indexing` (default `unlisted`) unless the user overrides it for this page.

## Output contract

A live, shareable URL for the page, backed by: a clean unique slug, a page matching site conventions, a 1200x630 OG image, share title and description, the correct robots/indexing directive, and a short report of the live URL and indexing state.

## Verification standard

Do not call the task done until: the page built and rendered locally, the deploy returned a live URL, fetching that URL returns 200 and renders, the OG image is exactly 1200x630 and resolves in the share preview, and the robots directive matches the chosen indexing. Build-time note: with no real site repo available, the end-to-end unlisted test page is run against the user's site on first real use; the OG-image step is statically verified to fail cleanly when image-gateway or its key is absent.
