---
name: visible-delegation
description: Delegate work to another agent session in a named, attachable tmux session the user can watch live — never a hidden background run. Launches the delegate with a self-contained goal prompt, monitors at sensible intervals against clear intervention triggers, runs the goal prompt's verification gates before reporting success, and closes the session rather than abandoning it. Trigger when the user asks to delegate, run something in parallel, or hand work to another agent.
tags: [agent-operations, delegation, tmux, supervision]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Visible Delegation

Delegation is only safe when it is supervisable. This skill hands work to another agent session inside a named tmux session the user can attach to and watch at any time. There are no hidden background runs: if the user cannot attach and see what the delegate is doing, the delegation has not happened correctly.

## Prerequisites

This skill requires tmux and the delegate agent CLI. Build-time check (2026-06-29): tmux 3.7 is installed at `/opt/homebrew/bin/tmux` and the `claude` CLI is installed at `/opt/homebrew/bin/claude`. Recorded assumption: delegate sessions run the `claude` CLI, since that is the agent CLI present on this machine. If tmux is missing on another machine, install it (`brew install tmux` on macOS, `apt-get install tmux` on Debian/Ubuntu) before launching. If the user runs a different delegate CLI, substitute its launch command in Step 3.

## When to use this skill

Invoke it when:

- The user asks you to delegate a task, hand work to another agent, or run a second agent on something.
- The user asks to run work in parallel with what the current session is doing.
- A task is well-scoped enough to package and supervise but large enough to be worth running alongside, not inline.

Do not invoke it for work the current session should just do itself, for a task too vague to write a goal prompt for, or when the user wants a fully unattended run they will not watch — this skill's whole point is visibility, so an unwatchable run is out of scope. If the task is not yet scoped, build the goal prompt first.

## Steps

### Step 1 — Confirm the delegation and scope the task

Confirm the user wants this work delegated to a separate session, not done inline. Identify the one task to hand off. Completion: an agreed, single delegated task.

### Step 2 — Build the goal prompt

Package the task into a self-contained goal prompt using the goal-prompt-generator skill if it is available; otherwise write an equivalent contract with objective, definition of done, repo constraints, verification gates, and stop conditions. The delegate has none of this session's context, so the prompt must carry everything. Completion: a self-contained goal prompt with verification gates.

### Step 3 — Launch the delegate in a named tmux session

Create a named tmux session and start the delegate agent in it with the goal prompt. Use a descriptive session name so its purpose is obvious:

```bash
SESSION="delegate-<short-task-name>"
tmux new-session -d -s "$SESSION"
tmux send-keys -t "$SESSION" "claude" Enter
# wait for the CLI to be ready, then paste the goal prompt as the first message
```

Save the goal prompt to a file and feed it in rather than typing a long string, when the CLI supports it. Completion: a detached, named tmux session is running the delegate with the goal prompt delivered.

### Step 4 — Tell the user how to attach and watch

Give the user the exact commands to watch the delegate live and to leave without killing it:

```bash
tmux attach -t delegate-<short-task-name>   # watch live
# press Ctrl-b then d to detach and leave it running
tmux capture-pane -pt delegate-<short-task-name>   # snapshot without attaching
```

Completion: the user knows how to attach, snapshot, and detach.

### Step 5 — Monitor at sensible intervals

Check the session periodically with `tmux capture-pane`, not constantly. Intervene when you see a real problem: the delegate is stuck in a loop repeating the same action, it has drifted outside the goal prompt's repo constraints (scope drift), or it is about to run a destructive or irreversible command. Otherwise be patient — slow progress on a hard step is not a reason to interrupt. Completion: the session is being checked on a sensible cadence with intervention reserved for stuck loops, scope drift, or destructive commands.

### Step 6 — Verify before reporting success

When the delegate claims completion, do not relay that claim. Run the verification gates from the goal prompt yourself and confirm each one passes. Only after the gates pass do you report success to the user. If a gate fails, the task is not done — feed the failure back to the delegate or surface it to the user. Completion: every verification gate has been run by you and the outcome is known.

### Step 7 — Close the session

When the work is verified done (or the user calls it off), close the tmux session rather than leaving it running:

```bash
tmux kill-session -t delegate-<short-task-name>
```

Confirm it is gone with `tmux ls`. Completion: the session is closed and no longer appears in `tmux ls`.

## Guardrails

- Never run the delegate as a hidden background process; it lives in a named tmux session the user can attach to, or the delegation does not happen.
- Never relay the delegate's completion claim as success without running the goal prompt's verification gates yourself first.
- Never leave a delegate session running after the work is done or called off; sessions get closed, not abandoned.
- Never let the delegate run a destructive or irreversible command unsupervised; that is an intervention trigger, not something to wait out.

## Output contract

A named, attachable tmux session running the delegate agent against a self-contained goal prompt; attach, snapshot, and detach commands given to the user; a monitoring cadence with defined intervention triggers; a verification step where the goal prompt's gates are run by this session before any success report; and a closed session at the end, confirmed gone from `tmux ls`.

## Verification standard

Do not call the task done until: the delegate ran in a named tmux session the user could attach to, the goal prompt was self-contained, the goal prompt's verification gates were run by this session and passed before success was reported, and the session was closed and confirmed absent from `tmux ls`. Acceptance test: delegate one small real task end to end while the user watches — launch, attach instructions, monitor, verify the gates, report, and close.
