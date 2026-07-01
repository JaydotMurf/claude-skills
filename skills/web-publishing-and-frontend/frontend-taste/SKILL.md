---
name: frontend-taste
description: A taste system that overrides default frontend instincts for all websites, apps, landing pages, and UI work. Sets layout, typography, and color rules, mandates a visual verification loop, and routes to nested sub-skills for minimalist/editorial, data-dense dashboard, premium marketing, and redesign-without-breaking work. Use at the start of any frontend design or implementation task.
tags: [frontend, design, ui, taste, verification, web-publishing-and-frontend]
audience: engineers, operators, and solo builders
source: open-skills
---

# Frontend Taste

The default look an agent reaches for is a hero, three feature cards, a default sans stack, and a purple gradient on white. This skill replaces that reflex with a stronger taste system: a small set of hard rules for layout, type, and color, a mandatory visual verification loop, and four nested sub-skills the core routes to by task type.

## When to use this skill

Invoke it at the start of any frontend work:

- Building or designing a website, web app, landing page, or any UI component.
- Restyling, theming, or polishing an existing interface.
- Any task where the output is something a person will look at and judge on appearance.

Do not invoke it for backend-only work, API design, CLI tools with no rendered UI, or copy edits that change no markup or styling. If the work produces no visual surface, this skill has nothing to verify.

## Taste references

This skill is stronger when anchored to two or three sites or apps the user admires and the reason why. Ask for them once at the start of a frontend engagement and record the answer where the work lives. Until the user supplies their own, this skill assumes these reference points and the principle each one teaches:

- Linear — restraint, a single confident accent, dense information that still breathes.
- Stripe — type scale discipline, real grids, color used sparingly and on purpose.
- Vercel — high-contrast minimalism, generous intentional whitespace, no decoration for its own sake.

Recorded assumption (build time): the user has not yet supplied personal references, so the three above stand in. Replace them the moment the user names their own; the rest of this skill does not change.

## Layout rules

- Vary deliberately. Never ship the default hero-plus-three-cards page; if a section repeats a pattern, that repetition must be a decision, not a fallback.
- Use real grids. Align to a consistent column structure; do not center everything in a single stacked column because it is easy.
- Use whitespace intentionally. Generous space is a tool for emphasis and grouping, not empty filler; every large gap should be doing a job.
- Establish hierarchy through scale and space before reaching for borders, boxes, or shadows.

## Typography rules

- Use a real type scale. Pick a ratio (for example 1.2 or 1.25) and size every text element on it; do not hand-pick arbitrary pixel values.
- Restrain pairings. One typeface, or two with a clear role split (one for display, one for text). Never more than two families.
- Set measure and line-height for reading. Body text holds a comfortable line length (roughly 60–75 characters) and line-height around 1.5.
- No default-stack sloppiness. If the design calls for a system stack, set it deliberately with weights and sizes; do not leave the browser default unstyled.

## Color rules

- Keep the palette restrained. A neutral foundation (a few grays, a background, a surface, a text color) plus one accent.
- Make one accent do real work. The accent marks the primary action and key emphasis; it is not sprinkled everywhere.
- Avoid the clichés. No purple-gradient-on-white as a default, no rainbow of unrelated hues, no gradient where a solid reads cleaner.
- Check contrast. Text on its background meets WCAG AA (4.5:1 for body) before the work is called done.

## Routing to sub-skills

After the core rules are set, route to the sub-skill that matches the task, and apply it on top of the core:

- Minimalist or editorial UI, content-forward pages, essays, reading experiences — `minimalist-editorial`.
- Data-dense dashboards, tables, admin panels, anything information-heavy — `data-dense-dashboard`.
- Premium marketing and landing pages, launch pages, anything selling — `premium-marketing`.
- Changing the look of an existing project without breaking it — `redesign-existing`.

If a task spans two (a marketing page with an embedded data section), apply the core rules once and pull the relevant section rules from each sub-skill. The core rules always win a conflict.

## Steps

### Step 1 — Classify the task and load references

Name which sub-skill the task maps to and confirm the taste references in play (the user's, or the recorded defaults). Completion: you know the task type and the references guiding it.

### Step 2 — Apply core rules, then the sub-skill

Design and implement against the layout, typography, and color rules above, then layer the matching sub-skill's specifics. Completion: the UI is built and every core rule has a deliberate answer in the result.

### Step 3 — Run the visual verification loop

This is mandatory and is not optional polish. Render the result and screenshot it (a real browser screenshot of the running page, not a guess from the code), then inspect the screenshot critically against the rules: hierarchy, alignment, scale, spacing, accent use, contrast. Write down what is weak. Fix the weakest items. Screenshot again. Repeat until nothing in the screenshot is weak. Completion: a screenshot exists, was inspected, and the last pass found nothing left to fix.

### Step 4 — Report

State which sub-skill was applied, what the verification loop caught and fixed, and link the final screenshot. Completion: the user can see what changed and why.

## Visual verification loop

The loop is the core of this skill and applies to every sub-skill:

1. Render the actual UI in a browser at a realistic viewport.
2. Screenshot it.
3. Inspect the screenshot, not the code, against the layout, type, and color rules.
4. List concrete weaknesses (misaligned column, weak hierarchy, accent overused, cramped measure).
5. Fix the weakest ones.
6. Screenshot again and repeat until a pass yields no weaknesses.

A change is never done on the strength of the code alone. The screenshot is the evidence.

## Guardrails

- Never call frontend work done without at least one screenshot inspected in the verification loop; code that "should look right" is not evidence.
- Never ship the default hero-plus-three-cards layout, a third type family, an unrestrained palette, or a purple-gradient-on-white as a fallback choice.
- Never override a user's stated taste references with the recorded defaults; the defaults apply only until the user names their own.

## Output contract

A built or restyled UI that satisfies the core layout, typography, and color rules and the applicable sub-skill, plus at least one inspected screenshot from the verification loop and a short report naming the sub-skill used and what the loop caught.

## Verification standard

Do not call the task done until: the matching sub-skill was applied, the visual verification loop ran with a real screenshot, the final inspection pass found no remaining weakness, and contrast meets AA. Build-time note: the bundle ships four sub-skills and a worked landing-section verification example under `examples/`; a live screenshot test requires a running target and is run against the first real frontend task.
