---
name: self-pr-merge
description: Review and merge a pull request the user authored themselves, with real review discipline despite GitHub disallowing self-approval. Runs a genuine fresh-eyes diff review first and surfaces findings before merging, checks CI and mergeability, merges with the user's chosen strategy, and cleans up the branch worktree-safely. Any failing check or unresolved finding halts the merge and returns to the user. Trigger when the user asks to merge their own PR or review-and-merge something they wrote.
tags: [agent-operations, github, pull-request, code-review]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Self PR Merge

GitHub will not let you approve your own pull request, which is correct — but it means a solo author can merge with no review at all. This skill supplies the missing discipline: a genuine review pass with fresh eyes before any merge, honest pre-merge checks, the merge itself, and clean teardown. The self-approval limitation is noted honestly, never worked around.

## Prerequisites and preferences

Requires the `gh` CLI, authenticated. Build-time check (2026-06-29): `gh` is authenticated to github.com as JaydotMurf with `repo` scope and ssh git protocol.

The build prompt asks for two preferences. Recorded assumptions (override on first real use):

- Merge strategy: squash. It keeps a clean linear history on the default branch, which fits this repo's PR-per-skill workflow.
- Branch cleanup: delete the remote branch after merge. For local worktrees, use worktree-safe removal.

If the user states different preferences, follow those; these defaults apply only when they do not.

## When to use this skill

Invoke it when:

- The user asks to merge their own PR, or to review-and-merge something they authored.
- The user has an open PR they want shipped and wants it reviewed first rather than merged blind.

Do not invoke it to review someone else's PR where normal approval applies (use a standard review flow), to merge without any review when the user explicitly waives it, or before the PR exists. This skill exists to put review discipline on self-authored merges; it is not a general merge button.

## Steps

### Step 1 — Confirm the PR and authentication

Confirm which PR to merge and that the user authored it. Confirm `gh auth status` is logged in. Completion: a specific self-authored PR and an authenticated `gh`.

### Step 2 — Genuine review pass, fresh eyes, findings first

Read the full diff as if someone else wrote it (`gh pr diff <number>`). Look for real problems: bugs, debug or commented-out leftovers, missing or weakened tests, scope creep beyond the PR's stated purpose, secrets or paths that should not be committed. List every finding and show it to the user before any merge. Finding nothing is a conclusion you reach by looking, never a default you assume — if the diff is clean, say so and say what you checked. Completion: a findings list (possibly empty, with what was reviewed) shown to the user before merge.

### Step 3 — Pre-merge checks

Check CI status, mergeability, and conflicts (`gh pr checks <number>`, `gh pr view <number> --json mergeable,mergeStateStatus,statusCheckRollup`). Note honestly that GitHub blocks self-approval, so this PR merges without a second approver — state the limitation, do not script around it (no approving from a second account, no disabling the rule). Completion: CI, mergeability, and conflict status are known and the self-approval limitation is stated.

### Step 4 — Stop if anything is unresolved

If any check is failing, the PR is not mergeable, there is a conflict, or a Step 2 finding is unresolved, halt and bring it back to the user. Do not merge over a red check or an open question. Completion: either everything is green and findings are resolved, or the merge is halted and handed back.

### Step 5 — Merge with the chosen strategy

Merge using the user's strategy (default squash):

```bash
gh pr merge <number> --squash    # or --merge / --rebase per preference
```

Completion: the PR is merged with the chosen strategy.

### Step 6 — Clean up the branch, worktree-safely

Delete the remote branch per preference (`gh pr merge` can do this with `--delete-branch`, or `git push origin --delete <branch>`). For local cleanup, if the branch is checked out in a git worktree, remove the worktree first with `git worktree remove <path>` — never run a plain `git branch -d/-D` against a branch that a worktree has checked out, which corrupts the worktree. Confirm teardown with `git worktree list` and `git branch`. Completion: the remote branch is deleted per preference and any worktree was removed with `git worktree remove`, confirmed clean.

## Guardrails

- Never work around the self-approval limitation; state it honestly and merge as the author, do not approve from a second account or disable the protection.
- Never treat "no findings" as a default; it is a conclusion reached only after actually reading the full diff, and the review must say what was checked.
- Never merge over a failing check, an unresolved conflict, or an open review finding; any of those halts the merge and returns to the user.
- Never delete a branch with plain branch deletion when a worktree has it checked out; remove the worktree first with `git worktree remove`.

## Output contract

A reviewed and merged self-authored PR: a findings list (empty or not, with what was reviewed) shown before merge, pre-merge check results with the self-approval limitation stated honestly, a merge using the user's chosen strategy, and worktree-safe branch cleanup confirmed clean — or, if any check or finding is unresolved, a halted merge handed back to the user.

## Verification standard

Do not call the task done until: the full diff was read and findings (or a clean conclusion with what was checked) were shown before merge, CI and mergeability were confirmed, the self-approval limitation was stated rather than bypassed, the merge used the chosen strategy, and branch cleanup used worktree-safe removal where a worktree was involved — confirmed by `git worktree list` and `git branch`. Acceptance test: run it on the user's next real PR.
