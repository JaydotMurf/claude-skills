# Runbooks

Compositions: each runbook chains existing skills into one repeatable outcome. A skill answers what an agent can do; a runbook answers what the system can reliably produce.

Expected: 7 runbooks.

Each runbook lives in its own folder as `runbooks/<runbook-name>/RUNBOOK.md`, built from the template in `templates/RUNBOOK-TEMPLATE.md`. Runbooks are generated after the skills they call exist, because a runbook may only name skills already in the library.
