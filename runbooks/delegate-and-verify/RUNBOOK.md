---
name: delegate-and-verify
description: Run parallel engineering lanes without becoming the bottleneck — record what each lane owns, package a task with its own acceptance test, delegate it in a watchable session, verify against the gates, merge, and close the loop.
tags: [agent-operations, delegation, engineering, verification]
audience: solo operators, engineering leads, GovTech teams
---

# Delegate and Verify

How one person runs parallel engineering lanes without becoming the bottleneck. You touch only the two decisions that need you: what done means, and whether the diff is good.

## Outcome

A delegated task carried from definition to merged PR, verified against the same gates it was issued with, with coordination state recorded and the waiting stakeholder told it landed.

## Skills it calls

1. `agent-operations/session-operating-map` — takes the set of concurrent concerns; produces or updates `docs/operating-map.md` with one lane per concern (name, objective, owner, state, blockers), so no delegate session needs the project re-explained. Hands the target lane's objective to the next step.
2. `agent-operations/goal-prompt-generator` — takes the lane objective; produces a self-contained goal prompt with an objective, a verifiable definition of done, may-modify and must-not-touch path lists, exact verification gates, and stop conditions. Hands the pasteable goal prompt to the next step.
3. `agent-operations/visible-delegation` — takes the goal prompt; runs the delegate agent in a named, attachable tmux session, then runs the prompt's verification gates before any success report. Hands the verified result and the gate output to the next step.
4. `agent-operations/self-pr-merge` — takes the verified branch; shows a findings list, runs pre-merge checks with the self-approval limitation stated honestly, and merges with the chosen strategy plus worktree-safe cleanup — or halts and hands back if any check is unresolved. Hands the merge outcome to the next step.
5. `agent-operations/stakeholder-update-email` — takes the merge outcome; drafts a what-changed / what-it-means / what's-next update and, on confirmation, sends it to whoever was waiting.

## Verification

- The operating map shows the lane with an owner and current state before delegation starts.
- The goal prompt carries verification gates as exact commands with expected results that cover its definition of done.
- The delegation session ran those gates and reported their output before claiming success; the tmux session is confirmed gone from `tmux ls` at the end.
- The merge step shows its findings list and pre-merge check results, and either merges cleanly or halts honestly.
- The update email claims only the verified, merged outcome.
