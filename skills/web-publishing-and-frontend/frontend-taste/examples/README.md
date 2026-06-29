# frontend-taste — worked example

A single premium-marketing landing hero section, built to the frontend-taste core rules and the `premium-marketing` sub-skill, then run through the mandatory visual verification loop. This is the build-time test the frontend-taste build prompt asks for.

## Files

- `landing-section.html` — the section. Self-contained, no external resources.
- `verify-desktop.png` — verification screenshot at 1280×800.
- `verify-mobile.png` — verification screenshot at a true 390 CSS-px width.

## What the loop caught and fixed

Pass 1 inspected the desktop and mobile screenshots against the core rules.

- Desktop: clean. One confident serif hero, single accent CTA, restrained warm-neutral palette with one accent (`#c2410c`) doing the work, generous intentional whitespace, a stat row off a divider for deliberate section variance, no purple-gradient-on-white.
- Mobile: defect found. The hero headline and lede overflowed the viewport horizontally. Root cause: the display type's minimum size (`clamp(2.5rem, …)`) was too large for a 390px column, and the headline lacked `overflow-wrap`.

Fix: lowered the display clamp minimum to `2rem` and scaled it on viewport width (`clamp(2rem, 7.5vw, 4.3rem)`), and added `overflow-wrap: break-word` to the heading.

Pass 2 re-inspected. A direct headless screenshot at `--window-size=390` still appeared clipped, but that is an old-headless artifact: headless clamps the layout to a ~500px minimum window width and scales the output down. Measuring the page inside a true 390px box reported `scrollWidth=390` with no overflowing elements, and a screenshot of the page in a 390px iframe (window 420px, above the clamp) renders correctly. `verify-mobile.png` is that honest 390-px render. Contrast meets WCAG AA for body and accent text.

## Reproduce the verification

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
# desktop
"$CHROME" --headless=new --disable-gpu --hide-scrollbars \
  --screenshot=verify-desktop.png --window-size=1280,800 \
  "file://$PWD/landing-section.html"
# true 390px mobile (iframe avoids the headless minimum-window clamp)
```

For the mobile shot, load `landing-section.html` in a 390px-wide iframe inside a ~420px window, or use a browser's device toolbar at 390px and screenshot. Do not trust a raw `--window-size=390` headless screenshot; verify the rendered width is actually 390 first.
