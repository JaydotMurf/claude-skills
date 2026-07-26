---
name: wayfinder
description: Plan a chunk of work too big for one agent session as a shared map of decision tickets on the repo's issue tracker, then resolve them one at a time until the way to the destination is clear. Use when the user explicitly runs /wayfinder with a loose idea to chart or an existing map to work; do not use for work small enough to plan and finish in a single session.
tags: [engineering, planning, issue-tracker]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
source: mattpocock
---

# Wayfinder

A loose idea has arrived — too big for one agent session, and wrapped in fog: the way from here to the destination isn't visible yet. Wayfinding is about finding that way, not charging at the destination. This skill charts the way as a shared map on the repo's issue tracker, then works its decision tickets — questions whose resolution is a decision, not slices of a build to execute — one at a time until the route is clear.

The destination varies per effort, and naming it is the first act of charting — it shapes every ticket. It might be a spec to hand off and iterate on, a decision to lock before planning starts, or a change made in place like a data-structure migration. The map is domain-agnostic — engineering work, course content, whatever fits the shape.

## Plan, don't do

Wayfinder is planning by default: each ticket resolves a decision, and the map is done when the way is clear — nothing left to decide before someone goes and does the thing. The pull to just do the work is usually the signal you've reached the edge of the map and it's time to hand off. An effort can override this in its Notes — carrying execution into the map itself — but absent that, produce decisions, not deliverables.

## Refer by name

Every map and ticket is an issue, so it has a name — its title. In everything the human reads — narration, the map's Decisions-so-far — refer to it by that name, never by a bare id, number, or slug. A wall of `#42, #43, #44` is illegible; names read at a glance. The id and URL don't vanish — a name wraps its link — but they ride inside the name, never stand in for it.

## The map

The map is a single issue on this repo's issue tracker, labelled `wayfinder:map` — the canonical artifact. Its tickets are child issues of the map.

The map is an index, not a store. It lists the decisions made and points at the tickets that hold their detail; a decision lives in exactly one place — its ticket — so the map never restates it, only gists it and links.

Where the map, its child tickets, blocking, and frontier queries physically live is tracker-specific. The issue tracker should have been configured for this repo — run /setup-skills if not. Consult the tracker doc's "Wayfinding operations" section for how this repo expresses them. If no tracker has been provided, default to the local-markdown tracker.

### The map body

The whole map at low resolution, loaded once per session. Open tickets are not listed — they are open child issues, found by query.

```markdown
## Destination

<what reaching the end of this map looks like — the spec, decision, or change this effort is finding its way to. One or two lines; every session orients to it before choosing a ticket.>

## Notes

<domain; skills every session should consult; standing preferences for this effort>

## Decisions so far

<!-- the index — one line per closed ticket: enough to judge relevance, then zoom the link for the detail the ticket holds -->

- [<closed ticket title>](link) — <one-line gist of the answer>

## Not yet specified

<!-- see "Fog of war": in-scope fog you can't ticket yet; graduates as the frontier advances -->

## Out of scope

<!-- see "Out of scope": work ruled beyond the destination; closed, never graduates -->
```

### Tickets

Each ticket is a child issue of the map; the tracker's issue id is its identity. Its body is the question, sized to one 100K token agent session:

```markdown
## Question

<the decision or investigation this ticket resolves>
```

Each ticket carries a `wayfinder:<type>` label — one of `research`, `prototype`, `grilling`, `task` (see Ticket types).

A session claims a ticket by assigning it to the dev driving the map, first, before any work, so concurrent sessions skip it. That assignee is the claim: an open, unassigned ticket is unclaimed.

Blocking uses the tracker's native dependency relationship — essential because it renders the frontier visually in the tracker's own UI, so the human sees what's takeable without opening the map. Only a tracker that lacks native blocking falls back to a body convention. A ticket is unblocked when every ticket blocking it is closed; the frontier is the open, unblocked, unclaimed children — the edge of the known.

The answer isn't part of the body — it's recorded on resolution (see Step 3 of Work through the map). Assets created while resolving a ticket are linked from the issue, not pasted in.

## Ticket types

Every ticket is either HITL — human in the loop, worked with a human who speaks for themselves — or AFK, driven by the agent alone. A HITL ticket only resolves through that live exchange; the agent never stands in for the human's side of it (a grilling agent that answers its own questions has broken this).

- Research (AFK): reading documentation, third-party APIs, or local resources like knowledge bases to surface a fact a decision waits on. Resolved by a research subagent — pair it with the current-info-search skill when the fact lives outside the repo. Use when knowledge outside the current working directory is required.
- Prototype (HITL): raise the fidelity of the discussion by making a cheap, rough, concrete artifact to react to — an outline, a rough take, a stub, or UI/logic code via the /prototype skill. Links the prototype as an asset. Use when "how should it look" or "how should it behave" is the key question.
- Grilling (HITL): conversation via the /grilling and /domain-modeling skills, one question at a time. The default case.
- Task (HITL or AFK): manual work that must happen before a decision can be made — nothing to decide, prototype, or research, but the discussion is blocked until it's done. Signing up for a service so its API can be judged, provisioning access, moving data so its shape can be seen. This is the one type that does rather than decides — and it earns its place by unblocking a decision, not by delivering the destination. The agent drives it alone where it can (AFK); otherwise it hands the human a precise checklist (HITL). Resolved when the work is done; the answer records what was done and any resulting facts (credentials location, new URLs, row counts) later tickets depend on.

## Fog of war

The map is deliberately incomplete: don't chart what you can't yet see. Beyond the live tickets lies the fog of war — the dim view of decisions and investigations you can tell are coming but can't yet pin down, because they hang on questions still open. Resolving a ticket clears the fog ahead of it, graduating whatever's now specifiable into fresh tickets — one at a time, until the way to the destination is clear and no tickets remain.

The map's Not yet specified section is where that dim view is written down: the suspected question, the area to revisit later. It's the undiscovered frontier toward the destination — everything here is in scope, just not sharp enough to ticket. Write as loosely or as fully as the view allows; it doubles as a signpost for collaborators reading where the effort is headed.

Fog or ticket? The test is whether you can state the question precisely now — not whether you can answer it now.

- Ticket when the question is already sharp — even if it's blocked and you can't act on it yet.
- Not yet specified when you can't yet phrase it that sharply. Don't pre-slice the fog into ticket-sized pieces: it's coarser than a ticket, and one patch may graduate into several tickets, or none, once the frontier reaches it.

Not yet specified excludes what's already decided (Decisions so far), what's already a live ticket, and what's out of scope (the next section).

## Out of scope

Fog only ever gathers toward the destination. The destination fixes the scope, so work beyond it is out of scope — it isn't fog, and it doesn't belong in Not yet specified. It gets its own Out of scope section on the map: work you've consciously ruled out of this effort. Scope, not sharpness, lands it here.

Out-of-scope work never graduates — the frontier stops at the destination — so it returns only if the destination is redrawn, and then as a fresh effort, not a resumption.

Ruling something out of scope is a scoping act, not a step on the route. When a ticket that already exists turns out to sit past the destination — mis-scoped in while charting, or exposed by a resolution — close it (a closed ticket is unambiguously off the frontier) and leave one line in the Out of scope section: the gist plus why it's out of scope, linking the closed ticket. It stays out of Decisions so far, which records the route actually walked — a scope boundary isn't a step on it.

## Steps

Two modes. The user's invocation decides: a loose idea charts a new map; a map reference (URL or number) works an existing one.

### Mode A — Chart the map

1. Name the destination. Run a /grilling and /domain-modeling session to pin down what this map is finding its way to — the spec, decision, or change. The destination fixes the scope, so it's settled first.
2. Map the frontier. Grill again, breadth-first this time: fan out across the whole space rather than deep on any one thread, surfacing the open decisions and the first steps takeable now. If this surfaces no fog — the way to the destination is already clear, the whole journey small enough for one session — you don't need a map. Stop and ask the user how they'd like to proceed.
3. Create the map (label `wayfinder:map`): Destination and Notes filled in, Decisions-so-far empty, the fog sketched into Not yet specified.
4. Create the tickets you can specify now as child issues of the map — then wire blocking edges in a second pass (issues need ids before they can reference each other). Wiring sorts them into the frontier and the blocked; everything you can't yet specify stays in the fog — the Not yet specified section.
5. Fire the research subagents. For each `research` ticket you just created, spin up a research subagent to resolve it in parallel, capturing its findings on a throwaway `research/<name>` branch with a context pointer from the ticket.
6. Stop — charting is one session's work; it hand-resolves nothing.

### Mode B — Work through the map

A ticket is optional — without one, you pick the next decision, not the user.

1. Load the map — the low-res view, not every ticket body.
2. Choose the ticket. If the user named one, use it. Otherwise take the first frontier ticket in order. Claim it: assign it to yourself before any work.
3. Resolve it — zoom as needed: fetch the full body of any related or closed ticket on demand; invoke the skills the Notes block names. If in doubt, use /grilling and /domain-modeling.
4. Record the resolution: post the answer as a resolution comment, close the issue, and append a context pointer to the map's Decisions-so-far.
5. Add newly-surfaced tickets (create-then-wire); graduate any fog the answer has made specifiable, clearing each graduated patch from Not yet specified so it lives only as its new ticket. If the answer reveals a ticket — this one or another — sits beyond the destination, rule it out of scope rather than resolving it on the route. If the decision invalidates other parts of the map, update or delete those tickets.

The user may run unblocked tickets in parallel, so expect other sessions to be editing the tracker concurrently.

## Guardrails

- Never resolve more than one ticket per session, with the single exception of research tickets fired as parallel subagents.
- Never work a ticket without claiming it first — assign it to the dev driving the map before any work begins.
- Never stand in for the human on a HITL ticket; it only resolves through the live exchange.
- Never restate a decision's detail on the map — the map gists and links; the ticket holds the detail.
- Never execute the destination's work from the map — produce decisions, not deliverables, unless the map's Notes explicitly carries execution into the effort.

## Output contract

Charting produces one map issue labelled `wayfinder:map` — Destination and Notes filled in, Decisions-so-far empty, fog sketched into Not yet specified — plus child decision tickets for every question sharp enough to state now, each labelled `wayfinder:<type>`, wired with the tracker's native blocking, with research subagents fired for each research ticket. Working produces exactly one resolved ticket: a resolution comment holding the answer, the issue closed, a one-line context pointer appended to the map's Decisions-so-far, and any newly-specifiable fog graduated into fresh tickets.

## Verification

Charting is done when:

- The destination survived a grilling session and reads as one or two lines every future session can orient to.
- Every ticket created states a question precisely, carries a `wayfinder:<type>` label, and sits correctly in the frontier or behind a blocking edge.
- Nothing that could be stated precisely is left in Not yet specified, and nothing vague was pre-sliced into tickets.

Working is done when:

- Exactly one non-research ticket was resolved: answer posted as a resolution comment, issue closed, context pointer on the map.
- Fog made specifiable by the answer was graduated into tickets and cleared from Not yet specified; invalidated tickets were updated, deleted, or ruled out of scope.
- The map still reads as an index — no decision detail restated on it.
