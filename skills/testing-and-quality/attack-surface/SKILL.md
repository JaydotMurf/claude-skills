---
name: attack-surface
description: >
  Maintain a living attack-surface inventory (attacksurface.md) of every
  deployed system, vendor, site, and credential store the user owns. Use
  when the user asks to build, update, or review their attack surface;
  when a new service is deployed, a vendor is added, a domain/DNS/auth
  change ships, or a secret store moves; or on an explicit
  /attack-surface invocation. Pairs with the assess-attack-surface
  workflow, which does the deep per-system assessment this file records.
tags: [security, inventory, attack-surface, infrastructure]
audience: Solo builders and operators running their own deployed systems
---

# Attack Surface

Keep one authoritative, continuously updated map of everything the user has deployed, so any assessment starts from a known inventory instead of rediscovering the estate each time. This skill owns the `attacksurface.md` file and its schema. It records inventory; it does not perform deep security testing. The deep testing belongs to the `assess-attack-surface` workflow, which reads this file and writes findings back into it.

## Purpose

A real attack surface is spread across repos, PaaS dashboards, DNS registrars, SaaS platforms, LLM vendors, and local credential stores, and no single tool sees all of it. This skill maintains a hand-curated inventory capturing, per system, what it is and how it can be reached. The file is the memory; the workflow is the muscle.

## When to use this skill

- The user says "build/update/review my attack surface", "what am I exposed", or runs `/attack-surface`.
- A new system is deployed, a new vendor or API is integrated, or a domain, DNS, DMARC, or auth change ships.
- A credential or secret store is added or moved.
- After an `assess-attack-surface` workflow run, to fold its findings back into the inventory.

Do not use this skill to perform a security assessment. Invoke the `assess-attack-surface` workflow for that, then use this skill to record the result.

## Where the file lives

The inventory holds real hostnames, vendors, and secret-store locations, so it must never land in a public or shared repo.

- Default location is the un-tracked `~/dev/` root at `~/dev/attacksurface.md`, outside every git repo.
- Before writing, confirm the target is not a pushed git working tree with `git -C <dir> rev-parse --is-inside-work-tree`.
- Honor lane separation: never inventory day-job or career-lane systems in the personal file.

## Per-system schema

Every system is one section with these twelve fields, in this order, omitting a field only when it genuinely does not apply.

1. Identity — one line: what it is, live URL or status, and repo.
2. Tech — languages, frameworks, server, ORM, database engine, notable libraries.
3. Hosting — self-hosted versus third-party, the provider, container or region, and any CDN, DNS, or mail in front.
4. Classification — web property, API, database, pipeline, CLI, or content, plus the concrete exposed surfaces.
5. Auth — how a user or client authenticates in, and any admin surfaces.
6. Vendors — each third-party integration and the credential type used against it.
7. Secrets — where secrets are stored or injected, with explicit confirmation of whether any are git-tracked.
8. Data — what is stored and its sensitivity.
9. Exposure — per audience: public, internal, localhost, VPN, token-required, or OAuth-gated.
10. Defenses — the controls actually in place.
11. Known-issue watchlist — the common misconfigurations for that specific platform stack, most-actionable first.
12. Testing cadence — recommended frequency plus a one-line rationale.

Group systems by criticality tier and keep a summary table at the top and a cadence table at the bottom. The tiers are T1 internet-exposed with money or PII, T2 internet-exposed with low or no sensitive data, T3 published on a managed platform or static host, and T4 localhost or not internet-reachable.

## Steps

### Step 1 — Locate or create the inventory

Read `~/dev/attacksurface.md` if it exists. If it does not, confirm the un-tracked location and create it from the schema with the summary and cadence tables. If it exists, work incrementally and never rewrite from scratch.

### Step 2 — Discover, do not assume

Gather real evidence before writing. Read deployment configs, `.env.example` and vendor references, READMEs and launch docs, live DNS and headers via `dig` and `curl -sSI`, and tracked-secret checks. For a broad estate, fan out read-only Explore agents, one per cluster of projects, each returning the twelve schema fields.

### Step 3 — Verify flags before recording them

Confirm a file is git-tracked with `git ls-files --error-unmatch <file>` before ever calling a secret "committed", since a gitignored local `.env` is normal. Downgrade or drop any flag that verification does not support and note the correction.

### Step 4 — Write or update entries

Write each system as a schema section under its tier, then update the summary table, the cadence table, and the sweep dates. Cross-link the machine-level credential section when a new secret store appears, and preserve existing watchlist items unless resolved.

### Step 5 — Assign a testing cadence

Set a cadence from criticality weighed against cost, so internet-exposed money or PII systems get frequent testing while localhost systems get per-release or event-triggered testing. State the rationale in one line and never put a T4 localhost system on an expensive calendar cadence.

### Step 6 — Report what changed

Summarize the systems added or updated, any new or resolved watchlist items, the most dangerous exposure found, and any cadence change. Point the user to the `assess-attack-surface` workflow to assess a specific system.

## Guardrails

- Never write the inventory into a git-tracked or public directory without confirming the target is un-tracked first.
- Never record a secret value; record type and location only.
- Never label a secret committed or leaked without confirming it is git-tracked.
- Never mix day-job or career-lane systems into a personal inventory.
- Never perform the deep assessment inside this skill; delegate testing to the `assess-attack-surface` workflow.
- Never silently delete or overwrite existing entries; update incrementally and note resolutions.

## Output contract

The skill produces or updates a single Markdown file at the confirmed un-tracked location. The file contains a top summary table, per-system sections following the twelve-field schema grouped by tier, a machine-level credential section, and a bottom cadence table with dated sweep and review lines. No secret values appear anywhere in it.

## Verification standard

Before calling itself done, the skill confirms: the file exists at an un-tracked path (`git rev-parse --is-inside-work-tree` is false or the path is outside any repo); every added system has all applicable schema fields populated; every "committed secret" claim was checked with `git ls-files --error-unmatch`; and the summary table, cadence table, and sweep date all reflect the change just made.

## Example

Input:

```
I just deployed a new Stripe-powered API on Railway. Update my attack surface.
```

Output:

```
Added payments-api under T1 (internet-exposed, handles money):
- Tech: Node/Express on Railway (container), Postgres (Railway managed)
- Auth: API key on client routes; Stripe webhook HMAC-verified
- Vendors: Stripe (secret key + webhook secret, env vars), Railway (dashboard secrets)
- Secrets: env vars in Railway; verified none tracked in repo
- Exposure: all endpoints public internet; no admin panel
- Watchlist: confirm CSRF on form POSTs, add security headers, verify
  webhook replay window, check Railway env-var scoping, confirm rate
  limiting survives restart
- Cadence: monthly + on every deploy (T1, money on the line)

Updated summary and cadence tables; Last full sweep set to today.
Run the assess-attack-surface workflow on payments-api for a full first pass.
```
