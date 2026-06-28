# Meta-prompts

The build prompts that generate each skill and runbook in this library. They are the source of record: a skill is produced by running its build prompt against an agent, then packaged to this repo's authoring standard.

Layout mirrors `skills/`, with one file per primitive:

```
meta-prompts/
  core-infrastructure/<skill-name>.md
  research-and-thinking/<skill-name>.md
  ...
  runbooks/<runbook-name>.md
```

Keeping the build prompt lets a skill be regenerated or improved later without reconstructing the original intent.
