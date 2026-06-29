---
# Required. The runbook name — matches the folder name.
name: your-runbook-name

# Required. One sentence: what outcome does this runbook produce?
description: Description of the outcome this runbook produces.

# Optional. Comma-separated list of relevant tags for discoverability.
tags: [publishing, research, media]

# Required. Who is the primary audience for this runbook?
audience: DoD contractors, veterans, solo operators
---

# Runbook Title

<!-- One or two sentences. What end-to-end outcome does this runbook produce? -->

## Outcome

<!-- The single concrete result the runbook delivers. Be specific about the finished artifact. -->

## Skills it calls

<!-- The ordered chain. Each step names one existing skill and the data handed to the next step.
     Every skill named here must already exist in skills/. The runbook owns flow, not procedure. -->

1. `category/skill-name` — what it takes in, what it hands to the next step.
2. `category/skill-name` — what it takes in, what it hands to the next step.
3. `category/skill-name` — what it takes in, what it hands to the next step.

## Verification

<!-- The evidence that must exist before the runbook's final output is called done.
     Pull the proof standard from the last skill in the chain and any cross-step checks. -->

- The final artifact exists at [location] and [check].
- [Cross-step check, e.g. the published URL resolves and the preview renders].
