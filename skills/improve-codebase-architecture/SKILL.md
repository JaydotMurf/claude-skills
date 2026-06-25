---
name: improve-codebase-architecture
description: Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick. Use when the user explicitly runs /improve-codebase-architecture or wants to surface architectural friction.
tags: [engineering, architecture, refactoring]
audience: Software engineers and developers using Claude Code
disable-model-invocation: true
---

# Improve Codebase Architecture

Surface architectural friction and propose deepening opportunities — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

This skill is informed by the project's domain model and built on a shared design vocabulary. Run `/codebase-design` for the architecture vocabulary (module, interface, depth, seam, adapter, leverage, locality) and its principles. The domain language in `CONTEXT.md` gives names to good seams; ADRs in `docs/adr/` record decisions this skill should not re-litigate.

## Steps

### Step 1 — Explore

Read the project's domain glossary (`CONTEXT.md`) and any ADRs in the area you're touching first.

Then use the Agent tool with `subagent_type=Explore` to walk the codebase. Don't follow rigid heuristics — explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules shallow — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called?
- Where do tightly coupled modules leak across their seams?
- Which parts are untested, or hard to test through their current interface?

Apply the deletion test to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal.

### Step 2 — Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory — nothing lands in the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp`. Write to `<tmpdir>/architecture-review-<timestamp>.html` so each run gets a fresh file. Open it for the user and tell them the absolute path.

The report uses Tailwind via CDN for layout and Mermaid via CDN for diagrams. Each candidate gets a card with:
- Files involved.
- Problem — why the current architecture causes friction.
- Solution — plain English description of what would change.
- Benefits — explained in terms of locality and leverage, and how tests would improve.
- Before/after diagram — side-by-side, illustrating the shallowness and the deepening.
- Recommendation strength — `Strong`, `Worth exploring`, or `Speculative`.

End the report with a Top Recommendation section: which candidate to tackle first and why.

Use CONTEXT.md vocabulary for the domain and the `/codebase-design` vocabulary for the architecture. If CONTEXT.md defines "Order", talk about "the Order intake module" — not the class name, not "the Order service."

If a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant reopening the decision. Mark it clearly.

See [references/HTML-REPORT.md](references/HTML-REPORT.md) for the full HTML scaffold, diagram patterns, and styling guidance.

After writing the file, ask the user: "Which of these would you like to explore?"

### Step 3 — Grilling loop

Once the user picks a candidate, run `/grilling` to walk the design tree — constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive.

Run `/domain-modeling` inline as decisions crystallise:
- Naming a deepened module after a concept not in `CONTEXT.md`? Add the term immediately.
- Sharpening a fuzzy term? Update `CONTEXT.md` right there.
- User rejects a candidate with a load-bearing reason? Offer an ADR so future reviews don't re-suggest it.
- Want to explore alternative interfaces? Use `/codebase-design` and its design-it-twice pattern.

## Guardrails

- Never propose interfaces during Step 2 — surface candidates only; design happens in Step 3.
- Never write the HTML report to the workspace — always write to the OS temp directory.
- Never re-litigate a decision that has an existing ADR unless the friction is significant enough to warrant it.
