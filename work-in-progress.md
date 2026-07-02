# agent-skills — Work In Progress

A living development map of the agent-skills project: what it is, what is built, what is underway, and where it is going. This file is the single source of truth for project state and is the basis from which the public README will be written before go-live.

Last updated: 2026-07-02 (main at the merge of PR #23 — first native adoptions of vendored skills).

---

## 1. Application Summary

agent-skills is a portable operating layer for AI agents. Where most agent setups carry knowledge in one sprawling system prompt that has to be re-explained every session and re-written for every tool, this project packages recurring agent work as version-controlled, model-agnostic procedures that any harness can read and run.

The library is built on the Open Skills framework. The atomic unit is a skill: one repeatable action defined in markdown, with a trigger that says when to fire, numbered steps, a hard guardrail, an output contract, and a verification standard the agent must meet before it calls the work done. Skills chain into runbooks: ordered compositions that turn a pile of primitives into an outcome a team can rely on — a voice memo becomes a published page, raw footage becomes a finished edit, a research question becomes a stress-tested briefing.

The audience is deliberate. This is a personal library, built first for the author's own professional and personal work and kept open for anyone who wants documented, auditable, repeatable AI procedures they can hand off, inspect, and trust — not a black box. Every skill is plain markdown plus, where needed, a small helper script. Nothing here is locked to one model provider or one vendor's harness. The same library runs across Claude Code, Codex, Gemini Antigravity, and anything else that reads a `SKILL.md` convention.

Three properties define the project:

- Portability: skills are canonical markdown, carried in source control, free of any single vendor's assumptions.
- Verifiability: every skill states its proof standard up front, so "done" means evidence exists, not that the agent produced confident language.
- Compounding: a session-to-skill extraction habit means useful procedures get preserved instead of dying in chat history, so the library gets more capable over time.

---

## 2. Features and Functionality

### Skill primitives

The core feature is the skill itself: a self-contained folder holding a `SKILL.md` that any agent harness can load by name. Each skill follows a six-element authoring standard — frontmatter, a trigger description, numbered steps, a "Never..." guardrail, an output contract, and a verification standard — so behavior is predictable and checkable. The library currently holds 58 skill folders across eight functional categories (48 native and 10 vendored), counting the four nested `frontend-taste` sub-skills.

### Runbook compositions

Runbooks chain existing skills into a single repeatable outcome. A runbook owns the sequence and the data passed between steps; each step names a skill that already exists and the artifact it hands forward. Seven runbooks are built, covering publishing, release briefings, video production, page QA, research, delegation, and the extraction flywheel.

### Eight functional categories

- core-infrastructure: the primitives other skills call — transcription, search, image generation, file ingestion, HTML artifacts.
- research-and-thinking: turn raw input (voice notes, meetings, document piles, weekly noise) into structured, reviewable thinking, plus design-interview skills that stress-test a plan.
- writing-voice-and-content: make agent writing sound like a specific person for a specific audience, and package release facts on-brand.
- web-publishing-and-frontend: take agent output public with taste, verification, branded imagery, and a repeatable publish procedure.
- video-and-media-production: the heaviest media skills — transcript-driven rough cuts, motion-graphics pipelines, and NLE scripting.
- testing-and-quality: make agent-built things trustworthy and the next session smarter — browser QA, test-runbook memory, TDD, and bug diagnosis.
- agent-operations: meta-skills about running agents well — delegation, goal prompts, operating maps, self-merge, session handoff, and skill extraction.
- software-engineering: design and ship code — module design, domain modeling, prototyping, and the planning-to-issues flow.

### Helper scripts and executable assets

Skills that touch external services or do real computation ship a small helper script next to their `SKILL.md`. The library includes shell scripts for search, transcription, ingestion, image generation, HTML validation, OG-image cropping, gallery building, model-arena pages, and email sending; Python scripts for the radio-edit and NLE-assistant; and a Remotion TypeScript component set for the b-roll graphics pipeline.

### Progressive disclosure

Skills push reference material that is not needed on every run into a `references/` subfolder loaded on demand, keeping the main `SKILL.md` lean. Examples include the codebase-design deepening notes, the domain-modeling ADR formats, the prompt-builder examples, and the visual-plan canvas and wireframe references.

### Secrets contract

Skills never store keys. Each skill reads its API key from an environment variable, trying its own per-skill override first and falling back to a shared provider key. Real keys live in `~/.config/agent-skills/.env` (chmod 600), outside the public repo, with only the `.env.example` contract committed. The design accepts a runtime secrets manager (1Password CLI, Doppler) without any change to a skill.

### Provenance and vendoring

Imported skills carry a `source:` field (for example `mattpocock` or `agent-native`) and, when kept close to upstream, a `standard: upstream-vendored` marker. Vendored skills are treated as dependencies rather than forks, so their upstream update paths survive; the conformance gap per vendored skill is tracked in `docs/vendored-conformance.md`.

### Three install methods

Skills install globally (every project on a machine), per-project (scoped to one repo, travels with a clone), or auto-invoked on session start (referenced from a project `CLAUDE.md`). The same leaf folder copies into any harness's skill directory.

### Build prompts and templates

Every native skill keeps the build prompt that generated it under `meta-prompts/`, mirroring the category layout, so a skill can be regenerated or adapted. Contributors start from `templates/SKILL-TEMPLATE.md` or `templates/RUNBOOK-TEMPLATE.md`.

---

## 3. Architecture

### 3.1 Directory structure

```
agent-skills/
├── CLAUDE.md                       # Project instructions (root)
├── .claude/
│   ├── CLAUDE.md                   # Same instructions, harness-loaded copy
│   └── settings.local.json
├── README.md                       # Public-facing overview
├── INSTALLATION.md                 # Three install methods + secrets
├── CONTRIBUTING.md                 # Submission process + acceptance criteria
├── CODE_OF_CONDUCT.md
├── CHANGELOG.md
├── LICENSE
├── .env.example                    # Committed secrets contract (no real keys)
├── .gitignore
├── work-in-progress.md             # This file
│
├── docs/
│   ├── open-skills-brief.md        # The framework brief grounding the library
│   ├── vendored-conformance.md     # Six-element gap tracker for vendored skills
│   └── verification-ledger.md      # Tier 3: dated live-run cost/shape evidence
│
├── scripts/
│   ├── check.sh                    # static + conformance gate (10 checks)
│   ├── test.sh                     # Tier 1: offline behavioral tests
│   ├── gen-index.sh                # generates the skills manifest
│   └── skills-index.json           # machine-readable manifest of all 58 skills
│
├── tests/
│   └── evals/                      # Tier 2: budget-gated LLM-judge eval scaffold
│       ├── run.sh                  # --validate (free) | --run (gated)
│       └── cases/                  # 7 runbook + 2 exemplar-skill cases + fixtures
│
├── templates/
│   ├── SKILL-TEMPLATE.md
│   └── RUNBOOK-TEMPLATE.md
│
├── skills/                         # 8 categories, 58 skill folders (39 native + 19 vendored)
│   ├── core-infrastructure/        # README + 5 skills
│   │   ├── current-info-search/    # SKILL.md + search.sh
│   │   ├── heavy-file-ingestion/   # SKILL.md + ingest.sh
│   │   ├── html-artifacts/         # SKILL.md + check.sh + template/example.html
│   │   ├── image-gateway/          # SKILL.md + generate.sh
│   │   └── media-transcription/    # SKILL.md + transcribe.sh
│   │
│   ├── research-and-thinking/      # README + 9 skills
│   │   ├── assumption-checker/
│   │   ├── brain-dump-processor/
│   │   ├── meeting-synthesis/
│   │   ├── reading-pack-builder/   # SKILL.md + template.html
│   │   ├── weekly-signal-diff/     # SKILL.md + state.example.json
│   │   ├── grilling/   grill-me/   grill-with-docs/   (vendored: mattpocock)
│   │   └── teach/                  # SKILL.md + references/ (vendored)
│   │
│   ├── writing-voice-and-content/  # README + 4 skills
│   │   ├── audience-content-system/
│   │   ├── branded-image-prompting/
│   │   ├── my-voice/
│   │   └── release-briefing/
│   │
│   ├── web-publishing-and-frontend/ # README + 10 leaf SKILL.md (6 top-level; frontend-taste = core + 4 nested)
│   │   ├── frontend-taste/         # SKILL.md + 4 nested sub-skills + examples/
│   │   │   ├── minimalist-editorial/
│   │   │   ├── data-dense-dashboard/
│   │   │   ├── premium-marketing/
│   │   │   └── redesign-existing/
│   │   ├── site-publisher/         # SKILL.md + make-og-image.sh
│   │   ├── image-model-arena/      # SKILL.md + arena.sh + example-config.json
│   │   ├── essay-illustration-gallery/ # SKILL.md + build-gallery.sh
│   │   ├── visual-plan/            # SKILL.md + references/ + agent-native-skill.json
│   │   └── visual-recap/           # SKILL.md + references/ + agent-native-skill.json
│   │
│   ├── video-and-media-production/ # README + 3 skills
│   │   ├── radio-edit/             # SKILL.md + radio-edit.py
│   │   ├── broll-pipeline/         # SKILL.md + orchestrate.sh + Remotion .ts/.tsx
│   │   └── nle-assistant/          # SKILL.md + nle.py
│   │
│   ├── testing-and-quality/        # README + 6 skills
│   │   ├── browser-qa/
│   │   ├── page-testing-memory/
│   │   ├── testing-runbook-creator/
│   │   ├── tdd/                    # SKILL.md + references/ (vendored)
│   │   ├── diagnosing-bugs/        # (vendored)
│   │   └── python-script-checker/  # (owned, built to standard)
│   │
│   ├── agent-operations/           # README + 13 skills
│   │   ├── goal-prompt-generator/  visible-delegation/  session-operating-map/
│   │   ├── self-pr-merge/  session-to-skill-extractor/  agentic-harness-designer/
│   │   ├── stakeholder-update-email/ # SKILL.md + send-update.sh
│   │   ├── ask-workflow/  handoff/  writing-great-skills/   (vendored)
│   │   ├── starting-project-session/ # (owned, built to standard)
│   │   ├── prompt-builder/         # SKILL.md + references/ (owned)
│   │   └── context-to-open-brain/  # (owned, built to standard)
│   │
│   └── software-engineering/       # README + 8 skills (all vendored: mattpocock)
│       ├── codebase-design/  improve-codebase-architecture/  domain-modeling/
│       ├── prototype/  setup-skills/  to-issues/  to-prd/  triage/
│
├── runbooks/                       # README + 7 runbooks
│   ├── talk-to-published/          release-day/          video-production-line/
│   ├── ship-a-page-you-can-trust/  research-engine/      delegate-and-verify/
│   └── flywheel/                   # each: RUNBOOK.md
│
└── meta-prompts/                   # 39 files: build prompts mirroring categories
    ├── README.md
    ├── core-infrastructure/ ... agent-operations/   (31 skill build prompts)
    └── runbooks/                   (7 runbook build prompts)
```

### 3.2 High-level architecture

The project is not a client-server application; it is an operating layer that loads into an agent harness. Mapped onto the conventional tiers, the agent harness is the frontend surface, the skill runtime is the middleware, the canonical library is the backend, and external services are the connectivity layer.

```
                            ┌──────────────────────────────────────────┐
   USER                     │              FRONTEND                     │
  ┌──────┐   /skill-name    │         Agent Harness Surface             │
  │ Human│ ───────────────► │  Claude Code · Codex · Gemini Antigravity │
  └──────┘   CLAUDE.md      │  - slash-command invocation               │
       ▲     auto-load      │  - CLAUDE.md auto-load on session start   │
       │                    │  - natural-language trigger match (descr.)│
       │ report / artifact  └───────────────────┬──────────────────────┘
       │                                         │ reads SKILL.md
       │                                         ▼
       │                    ┌──────────────────────────────────────────┐
       │                    │             MIDDLEWARE                     │
       │                    │            Skill Runtime                  │
       │                    │  - six-element procedure execution        │
       │                    │  - progressive disclosure (references/)   │
       │                    │  - helper scripts (.sh / .py / .tsx)      │
       │                    │  - secrets resolution (env var contract)  │
       │                    │  - output-contract + verification gates   │
       │                    └───────┬───────────────────────┬──────────┘
       │              reads canonical│                       │ calls
       │                            ▼                        ▼
       │      ┌────────────────────────────────┐   ┌────────────────────────┐
       │      │           BACKEND              │   │   EXTERNAL CONNECTIVITY │
       │      │     Canonical Library          │   │   APIs · MCP · Tooling  │
       │      │  skills/ (8 categories)        │   │  OpenRouter   Perplexity│
       │      │  runbooks/ (7)                 │   │  AssemblyAI   Resend    │
       │      │  meta-prompts/ · templates/    │   │  Open Brain MCP         │
       │      │  docs/ · provenance metadata   │   │  Chrome DevTools MCP    │
       │      └───────────────┬────────────────┘   │  GitHub/GitLab (gh/git) │
       │                      │ writes                Remotion+ffmpeg · Resolve│
       │                      ▼                     └────────────┬───────────┘
       │      ┌────────────────────────────────┐                │
       └──────┤   LOCAL ARTIFACT OUTPUTS        │◄───────────────┘
              │  ~/Documents, ~/Pictures, repo  │  generated files, reports,
              │  docs/, transcript/edit folders │  pages, EDLs, captures
              └────────────────────────────────┘
```

### 3.3 Low-level process flow (within the runtime)

This is the path a single skill invocation travels, from trigger to verified output.

```
  invoke /skill OR description-trigger match
                 │
                 ▼
        ┌──────────────────┐   missing config / no standard
        │ 1. Trigger check  │──────────────────────────────► STOP + ask user
        │  (when / when-not)│
        └────────┬─────────┘
                 ▼
        ┌──────────────────┐   reference needed?
        │ 2. Load procedure │────────────► read references/<topic>.md (on demand)
        │  SKILL.md steps   │◄────────────  return excerpt
        └────────┬─────────┘
                 ▼
        ┌──────────────────┐   needs a key?     ┌───────────────────────────┐
        │ 3. Resolve inputs │─────────────────► │ env: <SKILL>_API_KEY  ──►  │
        │  args + secrets   │                   │  fallback <PROVIDER>_API_KEY│
        └────────┬─────────┘                    └───────────┬───────────────┘
                 ▼                                           │ no key → clean fail
        ┌──────────────────┐                                 ▼
        │ 4. Execute steps  │── helper script (.sh/.py/.tsx) ── external call?
        │  numbered, in     │                                 │
        │  order, guardrails│◄──────────── stdout / file ◄────┘
        └────────┬─────────┘
                 ▼
        ┌──────────────────┐
        │ 5. Output contract│  produce the exact artifact shape promised
        └────────┬─────────┘
                 ▼
        ┌──────────────────┐   evidence missing → not done, loop or report gap
        │ 6. Verification   │──────────────────────────────────────────────►
        │  prove it / gate  │   evidence present → report result + artifact path
        └──────────────────┘
```

Runbook flow sits one level up: a runbook calls skills 1..N in order, taking the verified output artifact of each step as the input of the next.

```
  RUNBOOK (e.g. talk-to-published)
   step1 media-transcription ─► transcript.md
        └─► step2 brain-dump-processor ─► chosen idea
              └─► step3 my-voice ─► draft prose
                    └─► step4 html-artifacts ─► self-contained .html
                          └─► step5 site-publisher ─► live URL + OG image
                                                      (each arrow = verified handoff)
```

### 3.4 Third-party integration flow

Skills reach external services only through their helper scripts, and only with a key resolved from the environment. Below is every live integration and the skill that owns it.

```
   SKILL RUNTIME (helper script)            EXTERNAL SERVICE                PURPOSE
   ───────────────────────────────          ───────────────────             ───────────────────────
   image-gateway / generate.sh   ──HTTPS──► openrouter.ai/api/v1   ◄──PNG──  image generation
   current-info-search/search.sh ──HTTPS──► api.perplexity.ai      ◄──JSON─  dated live web search
   media-transcription/...sh     ──HTTPS──► api.assemblyai.com     ◄──JSON─  diarized transcription
   stakeholder-update-email/...sh──HTTPS──► api.resend.com/emails  ◄──id───  outbound email send
                                            (env keys, never stored in skill)

   context-to-open-brain         ──MCP────► Open Brain server      ◄───────  capture/search thoughts
   browser-qa                    ──MCP────► chrome-devtools-mcp    ◄───────  drive real Chrome, CWV

   self-pr-merge / setup-skills  ──CLI────► gh / git → GitHub/GitLab          PRs, issues, triage
   to-issues / triage

   broll-pipeline / orchestrate  ──local──► Remotion + ffmpeg                 ProRes 4444 graphics
   nle-assistant / nle.py        ──local──► DaVinci Resolve scripting API     timeline assembly

   Secrets path for every HTTPS integration:
     ~/.config/agent-skills/.env (chmod 600)  ──►  env var  ──►  helper script  ──►  API
     per-skill override key  ►  shared provider key  ►  clean no-key failure if neither set
```

---

## 4. Work Completed

Status legend: ✅ complete and verified. Verification method is noted because several paid or hardware-dependent paths are static-verified (syntax, schema, no-key guard) with live runs deliberately deferred to first real use.

### Repository foundation

- ✅ Repository renamed to agent-skills and restructured to the Open Skills framework (Approach C: taxonomy-first, adapters deferred).
- ✅ Eight-category taxonomy established under `skills/`.
- ✅ Six-element skill authoring standard and runbook authoring standard documented in both `CLAUDE.md` files.
- ✅ Secrets contract defined in `.env.example` (OpenRouter, Perplexity, AssemblyAI, Resend, plus per-skill overrides); real keys kept outside the repo; `.gitignore` covers env files, caches, and build artifacts.
- ✅ Governance docs in place: `README.md`, `INSTALLATION.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `CHANGELOG.md`, `LICENSE`.
- ✅ Templates committed: `SKILL-TEMPLATE.md`, `RUNBOOK-TEMPLATE.md`.
- ✅ Framework brief written: `docs/open-skills-brief.md`.

### Core infrastructure (5 skills) — PR #1, merged

- ✅ image-gateway, current-info-search, media-transcription — live-tested against real APIs; shapes and per-call costs recorded in each `SKILL.md`.
- ✅ heavy-file-ingestion, html-artifacts — tested on local paths.

### Research and thinking (5 native) — merged

- ✅ assumption-checker, brain-dump-processor, meeting-synthesis, reading-pack-builder, weekly-signal-diff — built to the six-element standard, static-verified (bash/jq/schema where applicable).

### Writing, voice, and content (4) — merged

- ✅ audience-content-system, branded-image-prompting, my-voice, release-briefing — built and static-verified; voiced output composes my-voice.

### Web publishing and frontend (4 native, +4 nested) — PR #4, merged

- ✅ frontend-taste core plus four nested sub-skills; visual-verification loop exercised against a real landing hero (caught and fixed a mobile overflow bug).
- ✅ site-publisher (explicit-trigger publish; `make-og-image.sh` crops to exact 1200x630).
- ✅ image-model-arena, essay-illustration-gallery — compose image-gateway and site-publisher; scripts static-verified; live paid generation deferred.

### Video and media production (3) — PR #6, merged

- ✅ radio-edit (transcript-driven paper edit + CMX3600 EDL / FCPXML 1.13).
- ✅ broll-pipeline (SCOUT + BUILDER subagents, Remotion transparent ProRes 4444, ffmpeg composite, resume state).
- ✅ nle-assistant (DaVinci Resolve scripting; always works on a safety copy). All static-verified (py_compile, bash -n, jq); live renders and NLE round-trips deferred.

### Testing and quality (3 native) — PR #5, merged

- ✅ browser-qa, page-testing-memory, testing-runbook-creator — built and static-verified; browser-qa drives a real Chrome via chrome-devtools-mcp.

### Agent operations (7 native) — PR #7, merged

- ✅ goal-prompt-generator, visible-delegation, session-operating-map, self-pr-merge, stakeholder-update-email, session-to-skill-extractor, agentic-harness-designer.
- ✅ stakeholder-update-email verified against the Resend API shape; live send deferred.

### Runbooks (7) — PR #8, merged

- ✅ talk-to-published, release-day, video-production-line, ship-a-page-you-can-trust, research-engine, delegate-and-verify, flywheel.
- ✅ All 26 referenced `category/skill` paths verified to resolve; data-flow lines use real artifact names from each skill's output contract.

### Flat-skill reconciliation Pass 1 (23 skills) — PR #9, merged

- ✅ All 23 pre-existing flat skills relocated into categories via `git mv` (history preserved).
- ✅ New eighth category `software-engineering/` created.
- ✅ Provenance recorded: 17 `source: mattpocock`, 2 `source: agent-native`, 4 owned with no source; vendored skills marked `standard: upstream-vendored`.
- ✅ Repo docs updated to eight categories and the provenance convention.

### Flat-skill reconciliation Pass 2 — PR #10, merged

- ✅ Four owned skills brought to the full six-element standard (python-script-checker built out from a stub; open-brain-capture, prompt-builder, starting-project-session given explicit output and verification sections).
- ✅ `docs/vendored-conformance.md` tracks the six-element gap for all 19 vendored skills without modifying vendored content.
- ✅ Confirmed ask-workflow routes by command name, not path, so reconciliation broke no cross-skill references (repo-wide grep clean).

### Cross-skill fix, hygiene, and CI

- ✅ image-gateway reads `IMAGE_GATEWAY_MODEL` (falling back to the Nano Banana default), closing the recorded build-time dependency so image-model-arena can drive a model per call; both SKILL.md docs updated.
- ✅ Stray local `__pycache__` artifacts removed (already gitignored, never tracked).
- ✅ Continuous integration stood up: `scripts/check.sh` plus `.github/workflows/ci.yml` run on every push and PR — shell/Python/JSON syntax, the six-element check for native skills, vendored provenance integrity, runbook-reference resolution, and the writing-rule lint. Verified green on main (39 native skills, 19 vendored, 35 runbook references, 45 procedures). Documented in CONTRIBUTING.md.
- ✅ Open Brain capture upgraded: the proactive, technically richer `context-to-open-brain` supersedes the user-invoked `open-brain-capture` as the single canonical capture skill (richer categories — repo structure, scripts, env vars, APIs, conventions — third-person voice, and proactive session-end triggering), built to the six-element standard and lint-clean. The superseded skill was removed to avoid drift.

### Live paid-path validation (2026-07-01)

All API-backed skills with a key present were validated against real endpoints for the first time, staying under a ~$15–20 ceiling for about $0.44 total. Each touched `SKILL.md` now carries a dated evidence line with real cost and confirmed output shape.

- ✅ current-info-search — live re-confirmed at $0.00525/query, and a real bug was fixed: the recorded `/v1/sonar` endpoint throws an HTTP/2 framing error, so `search.sh` was switched to the documented `/chat/completions` and now prints real `usage.cost.total_cost`.
- ✅ media-transcription — a 25-second two-topic clip produced the full four-artifact package (65 words, one auto-chapter) for well under a cent.
- ✅ image-gateway — default model at $0.0387657, and the PR #12 `IMAGE_GATEWAY_MODEL` override proven live by routing the same call to `google/gemini-3-pro-image` ($0.13616); the different model id and cost confirm the env var drives selection.
- ✅ image-model-arena — a two-model composer run recorded per-image cost to `registry.json`; caveat logged that the example config's `flux-1.1-pro` is not an image-output model on OpenRouter today.
- ✅ essay-illustration-gallery — a two-frame composer run produced a self-contained HTML with base64 images and zero external references, style descriptor locked across frames.
- ✅ stakeholder-update-email — `--reply-to` was added (the header had long claimed it but the code never sent it) and a live send via the Resend sandbox sender returned a message id; sandbox delivery is limited to the account's own email until a custom domain is verified.

The remaining deferred paths are hardware and render dependent (radio-edit, broll-pipeline, nle-assistant) and the Remotion typecheck, all tracked below.

### Tiered quality-test system (PR #16)

A three-tier verification system so "verified" is enforced by tooling, not asserted in prose. The design was chosen from three graded options (deterministic-only, LLM-judge-only, tiered pyramid); the pyramid won on cost, CI-safety, and fit with the existing gate.

- ✅ Tier 1, the deterministic CI gate: `scripts/gen-index.sh` emits `scripts/skills-index.json` (a manifest of all 58 skills that also seeds a future dependency graph); `scripts/test.sh` runs 15 offline behavioral tests (Python selftests, clean no-key failure in a scrubbed env, usage/arg validation, HTML offline-safety); `radio-edit.py` gained a `selftest` for its pure edit logic; and `scripts/check.sh` grew three checks (manifest freshness, non-empty contract/verification sections, runbooks composing at least two skills). Both scripts are wired into CI.
- ✅ Tier 2, behavioral evals: `tests/evals/` scores skills and runbooks against rubrics drawn from their own verification standards, seeded with all 7 runbooks and 2 exemplar skills. `run.sh --validate` is free and offline; the judged run is gated behind a key and budget flag and kept off the pull-request gate.
- ✅ Tier 3, the verification ledger: `docs/verification-ledger.md` records dated live-run cost and shape evidence, populated from the paid-path validation pass above.
- ✅ A cross-platform manifest bug was found and fixed during the build: the freshness check must compare content, not byte formatting, because jq output differs by version and locale between macOS and the Ubuntu CI runner. The manifest is now byte-identical across locales.

### Public README rewrite (PR #17)

- ✅ `README.md` rewritten into a clean, professional landing page: correct scope (58 skills across eight categories, 7 runbooks), a CI status badge, and a "Built to be trusted" section surfacing the per-skill proof standards, the runtime secrets contract, and the three-tier verification. The full go-live README can still expand from this file, but the public front door is now accurate and presentable.

---

## 5. Work In Progress

Paid-path validation, the tiered quality-test system, and the README rewrite are all done (see Work Completed). What remains is hardware-dependent validation, the phase-2 build, and ongoing native adoption of vendored skills.

1. Live-validate the hardware and render paths: a radio-edit EDL imported into an NLE, a broll-pipeline end-to-end render, and an nle-assistant round-trip against DaVinci Resolve Studio. Blocked on local media hardware and toolchains.
2. Add a Remotion typecheck for `broll-pipeline/index.ts` and the `.tsx` set, which are not type-checked in this repo today (no Remotion toolchain present); wire it into CI once the toolchain is available.
3. Grow the Tier 2 eval suite past its seed set (7 runbooks + 2 exemplar skills) and, when a model budget is approved, wire the judged run so it produces a scored report.
4. Continue native adoption of vendored skills where it pays off: pick the highest-traffic vendored skills, bring each to the six-element standard, drop its `standard: upstream-vendored` marker, and remove its row from `docs/vendored-conformance.md`. Nine adopted so far — `software-engineering/codebase-design`, `web-publishing-and-frontend/visual-plan`, `web-publishing-and-frontend/visual-recap`, the four `research-and-thinking` interview/teaching skills (`grilling`, `grill-me`, `grill-with-docs`, `teach`), and `testing-and-quality/tdd` + `testing-and-quality/diagnosing-bugs` now carry an Output contract and a Verification section and pass the native gate (the two visual skills also had their inline bold stripped to clear the writing-rule gate); 10 vendored skills remain.
5. Build the phase-2 per-harness adapter and generation layer: flatten canonical `SKILL.md` into each harness's expected location and generate per-tool rule files (Claude Code, Codex, Cursor, Gemini) from the single canonical source.
6. Optional: verify a Resend custom domain so stakeholder-update-email can send beyond the account's own inbox; blocked on owning and verifying a domain.

---

## 6. Future Improvements

Ten concepts to push the project past a static library into a product, spanning capability, security, performance, and go-to-market.

1. Skill dependency resolver and graph. Parse every runbook and skill to build a dependency graph, validate that a composition only names skills that exist, detect cross-skill couplings (like the image-gateway model dependency) automatically, and render the graph as a navigable map of the whole operating layer.

2. `agent-skills` package manager. Ship an `npx agent-skills` CLI that installs, updates, and removes skills across any harness, treats vendored skills like versioned dependencies with a lockfile, and pulls upstream updates (mattpocock, agent-native) on command without losing local provenance.

3. Verification ledger and run telemetry. An opt-in, local-first record of each skill's last successful run, its evidence, and its cost, so a user can see at a glance which skills are battle-tested versus static-verified, and so the per-`SKILL.md` cost notes stay current automatically.

4. Embedding-powered skill router. Tie the library into Open Brain so a user describes a situation in natural language and the system retrieves the right skill or runbook by meaning, retiring the need to remember names — effectively a smarter, semantic ask-workflow.

5. Sandboxed execution with a secrets broker. Run helper scripts in a locked-down sandbox with no ambient network or filesystem access, inject keys at runtime from 1Password CLI or Doppler scoped to the single skill that needs them, and revoke per-skill — turning the env-var contract into an enforced boundary, which matters in any security-conscious environment.

6. Conformance CI bot. A GitHub Action that scores every pull request against the six-element standard and the writing rules, auto-comments the gaps inline, and blocks merge until an owned skill conforms — making the quality bar self-enforcing instead of reviewer-dependent.

7. Signed, provenance-verified skill registry. A public registry where community skills carry a cryptographic signature and a provenance chain (sigstore-style), so a contractor can prove a skill's origin and integrity before installing it — a verifiable software supply chain for agent procedures.

8. Cost-aware model routing. Let image-gateway and current-info-search choose the cheapest model that clears a stated quality bar, enforce a per-session and per-month budget guardrail, and report spend, so heavy media runbooks stay predictable and affordable.

9. Compliance and audit pack for regulated environments. A generated, exportable audit bundle — which skill ran, what it touched, what evidence it produced, which sources and dates it verified — mapped to controls a security or compliance reviewer recognizes, turning the verification standard into a portable compliance artifact.

10. Self-hosted gallery and onboarding flywheel. Dogfood the library's own site-publisher and frontend-taste skills to publish a live gallery that demonstrates each skill and runbook with real examples, paired with a guided onboarding runbook that uses the teach skill to walk a newcomer from zero to a working operating layer — the library demonstrating itself.

---

This document is the development map. Keep it current as work lands: move items from Work In Progress to Work Completed with their verification method, and revisit Future Improvements as the roadmap firms up. It is the direct source for the public README at go-live.
