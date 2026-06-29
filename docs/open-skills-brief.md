# Open Skills: a technical brief

Open Skills is a method for packaging recurring agent work as portable, version-controlled
procedures instead of explaining that work to an agent through prompts each time it runs. The unit
of work is a primitive called a skill: one atomic, repeatable action defined in markdown. Primitives
chain into compositions called runbooks. The result is an operating layer that lives in source
control, runs across any agent harness that reads a SKILL.md style convention, and stays consistent
regardless of model provider. This brief defines the framework, the separation between primitives
and compositions, and the methodology for creating, scoping, and verifying these procedures. It is
written for integration into a systems engineering documentation repository and is grounded in the
practice of the agent-skills repository that contains it.

## Provenance

Two sources informed this brief: a recorded talk (`https://youtu.be/9PUaEj0pMYE`), whose transcript
the user supplied in full, and the Open Skills framework page
(`https://unlock-ai.natebjones.com/open-skills/skills`). The framework page is partly rendered by
client-side JavaScript, so automated fetch recovered only fragments; the transcript fills the rest.
From these sources: the library currently holds 31 skills in 7 categories plus 7 runbooks, each skill
ships with a copy-paste setup prompt to build the primitive against your own agent and stack rather
than as a finished artifact, and the pattern is designed to load across Codex, Claude Code, and any
other harness that reads a SKILL.md convention. Claims about concrete file mechanics are drawn from
the practice of this repository and are marked "repo practice" where they extend beyond the source,
so the brief does not present local convention as framework canon.

## Procedural debt

Open Skills addresses a problem that appears once the memory problem is solved. An agent can know the
project, the people, and the decision history and still not know how you work. It still has to be told
not to trust stale model memory when researching, not to sound like a generic newsletter when writing,
to actually open a browser and check mobile and capture evidence when testing, and to verify the live
result when publishing. That is not a memory gap. It is procedural debt, and it surfaces in four
places in serious agent workflows.

- Prompt bloat: rules pile into one large system prompt or markdown file until every preference, edge case, and reminder competes for attention and the agent gets worse.
- Re-explanation tax: every fresh session and every switch between tools forces the operator to restate voice, testing standard, project patterns, safe commands, and definition of done again.
- Instruction fragmentation: one set of rules lives in one tool, another in a second tool, repo notes in a third, and the copies drift apart after any one of them is updated.
- Weak verification: the agent reports done while the source is stale, the link is broken, or the change was never tested, which moves the work into the human review stage instead of removing it.

The illustrative case is a small team shipping one codebase through both Cursor and Claude Code. They
tuned a strong set of Cursor rules, then needed Claude Code for larger multi-file changes, and the
rules did not travel cleanly. One engineer ended up maintaining two copies of the same guidance that
drifted apart, and a new contractor was handed an onboarding prompt that read as comprehensive but was
vague on the details that actually prevented bad edits. The team was not short on intelligence or
context. It was short on a portable way to carry the procedure itself.

## Relationship to Open Brain

Open Skills is the procedural counterpart to Open Brain. Open Brain gives an agent portable context:
what you are working on, what you decided last week, who the important people are, and what you already
tried, held as memory that is not trapped inside one app or model provider. Open Skills gives the agent
portable procedure: how to research, write, build, test, publish, and report what changed. The two
compound for the same reason. Open Brain improves because every captured thought makes future retrieval
better; Open Skills improves because every preserved procedure makes future work more reliable. Context
without procedure still forces re-explanation; the operating layer is the pair together.

## Primitives and compositions

The framework's central technical separation is between primitives and compositions.

A skill is a primitive: a single atomic action that one agent can perform repeatably and that can be
verified on its own. In practice it is a small folder with a SKILL.md inside, and the file states when
to use the skill, when not to use it, what job the skill owns, what tools or files it should touch, what
boundaries apply, what the output should look like, and how to verify the result. A prompt is something
you say once; a skill is something the agent knows how to do from now on. Three examples make the
distinction concrete:

- A current-information-search skill says to use live search when a claim is recent or a price or software version may have changed, to compare sources and show dates, to separate confirmed facts from inference, and to let uncertainty block publishing.
- A personal-voice skill names which real writing samples to read, which phrases to avoid, the sentence length and argument structure that work, and the generic AI phrasing to strip out.
- A browser-QA skill says to open the actual route, check the console, check mobile, verify the changed workflow, capture screenshots, and report the evidence rather than a verdict.

This repository encodes that primitive specification as a four-element authoring standard: frontmatter
with name, description, tags, and audience; a trigger description stating the exact conditions under
which the skill fires; numbered steps the agent follows in order; and at least one guardrail written as
a "Never..." imperative. A skill missing any of the four is not merge-ready (repo practice). Isolated
execution is what lets a primitive be reasoned about on its own: a skill marked `context: fork` runs in
isolation with a read-only snapshot of the parent context, and the main thread sees only the return
value (repo practice). A primitive that cannot mutate surrounding state can be tested, swapped, and
composed without side effects on the caller.

A runbook is a composition: an ordered chain of primitives directed at an outcome. A skill answers what
the agent can do; a runbook answers what the system can reliably produce. Each primitive owns one
contract and the runbook owns the flow and the data passed between steps, so the transcription step
never needs to know how to publish and the publisher never needs to know how to generate visuals. Two
worked examples from the source:

- Creator workflow, a voice memo to a published page: media transcription, then brain-dump processing to separate ideas from rambling, then personal voice to draft, then an HTML artifact builder, then a site publisher that ships with the right route, metadata, link preview, and verification.
- Release day, facts to a published briefing: current-information search to gather facts, a new-release briefing to package them, image prompting and generation for the visual, the site publisher to ship, and a stakeholder update to close the loop once the page is live.

This repository currently implements primitives only and does not yet contain a runbooks layer, so
runbooks are described here as the framework concept rather than as existing repository structure
(repo practice).

## Methodology: create, scope, verify

### Create

A skill begins as a recurring multi-step task where prompt-based explanation has become redundant or
error-prone. The framework ships each skill as the prompt to build the primitive against your own
agent, defaults, and stack, so creation means adapting that build prompt until the resulting procedure
belongs to your workflow rather than the library's. The trigger is concrete: do something with an agent
once and a prompt is fine, but the second time you explain the same steps, that task is a skill
candidate.

### Scope

Scope each primitive to the smallest unit that makes the next workflow repeatable, and place it where
it belongs. A procedure that is yours, such as your voice or your publishing standard, has personal
scope and lives globally; a procedure that belongs to a repository, such as how to test that app or the
safe commands and seed data for that project, has project scope and lives with the project. One skill
performs one action, such as formatting a specification or running a single validation script. When a
skill accumulates reference material not needed on every run, push it down the information hierarchy:
this repository's `skills/writing-great-skills` defines three rungs, an in-skill step, an in-skill
reference consulted on demand, and an external reference reached by a pointer and loaded only when the
pointer fires (repo practice). An all-reference skill with no procedural flow still satisfies the
numbered-steps requirement with a single step that loads and applies the reference wrapper (repo
practice).

### Verify

Verification is part of the skill's contract, not a vibe left to the operator. The skill states the
proof ahead of time: do not call this done unless this evidence exists. If the agent edited code, which
test passed; if it built a page, which browser opened and what did mobile look like; if it published,
which URL did it check; if it summarized a source, which source did it read; if it used current facts,
which date did it verify. Agents are good at producing plausible completion language and less reliable
when the definition of done is vague, so each step ends on a completion criterion the agent can check.
The `mss-sop-generator` skill is a concrete instance: a three-file primitive (SKILL.md, REFERENCE.md,
EXAMPLES.md) whose reference carries a `[DOC]` and `[VALIDATED]` marking on every procedure and a rule
for what to do when documented and validated steps conflict (repo practice). One caveat applies to
user-invoked skills: a skill marked `disable-model-invocation: true` cannot be invoked by the agent
through a slash command, so the agent executes its steps by hand and verification is performed step by
step rather than through a single end-to-end call (repo practice).

## Open as portability, not publication

Open here means practical portability, not that every skill is public by default and not that secrets
go in a shared file. The skill becomes the single source of truth, and tool-specific rule systems such
as Cursor rules, Claude Code files, and Codex instructions read from it or are generated from it instead
of becoming separate drifting copies. Storing the library in version control with consistent lowercase
hyphenated directory names lets an agent locate that source of truth regardless of the harness it runs
in. Because the skills are markdown instruction sets rather than provider-specific code, the same
library runs across tools and model providers, which is what frees the operator from the memory and
workflow assumptions of any single vendor.

## The extraction flywheel

The library grows through a post-session review habit rather than up-front design. The framework names
this as a session-to-skill extractor: at the end of a substantial session, ask whether the work
revealed a recurring, non-obvious procedure worth preserving. Most of the time the answer is no, and
that restraint is part of the quality bar, because not every preference should become a skill. When the
answer is yes, the procedure becomes a skill candidate instead of disappearing into old chat history.
The two signals to watch are a manual correction of the agent's output and a constraint explained more
than once. This is the same compounding logic as Open Brain applied to procedure rather than memory.

## The 5 Ws

| Question | Answer |
|---|---|
| Who | Knowledge workers and engineers managing multi-tool agent environments who want to eliminate procedural debt. |
| What | A portable library of reusable agent procedures packaged as primitives (skills) and compositions (runbooks). |
| Where | Any agent harness that reads a SKILL.md convention, with consistent behavior regardless of model provider. |
| When | Any time a recurring task needs multiple predictable steps and prompt-based explanation has become redundant or error-prone. |
| Why | To replace ephemeral, bloated system prompts with a version-controlled, verified, portable operating layer that compounds over time. |

## Adoption sequence

1. Stand up a version-controlled skills directory with consistent lowercase hyphenated naming.
2. Capture the highest-frequency recurring task as a single primitive carrying a trigger, a boundary, an output shape, and a proof standard.
3. Place each skill in the right scope: global when the procedure is yours, project-local when it belongs to a repository.
4. Run a post-session review and extract a new primitive only when a correction repeats or a constraint is explained twice.
5. Once several primitives exist, compose a runbook that chains them, keeping each step independently verifiable.
