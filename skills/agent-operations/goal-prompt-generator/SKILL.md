---
name: goal-prompt-generator
description: Turn an implementation plan or task description into a bounded, self-contained goal prompt that another agent session can execute autonomously and be checked against. Every prompt carries a one-paragraph objective, a verifiable definition of done, repo constraints (what may and may not be touched), exact verification gates, and explicit stop conditions. Trigger when the user asks to package work for another session, write a goal prompt, or prepare a task for autonomous execution.
tags: [agent-operations, delegation, planning, goal-prompt]
audience: engineers, operators, and solo builders
source: open-skills
---

# Goal Prompt Generator

A goal prompt is the contract a receiving agent session works against. The receiving session has none of the conversation context that produced the plan, so the prompt has to carry everything the work needs and everything the result will be checked against. This skill turns a plan or task description into that contract.

## When to use this skill

Invoke it when:

- The user asks you to package work for another session, write a goal prompt, or prepare a task for autonomous or unattended execution.
- The user is about to delegate work (for example via the visible-delegation skill) and needs the task written down first.
- The user wants a task scoped so its result can be verified without re-deriving the plan.

Do not invoke it for a task the current session will execute itself, for a quick one-line instruction that needs no verification contract, or when the user wants to discuss the plan rather than freeze it into a prompt. A goal prompt is for handing work away, not for thinking out loud.

## Required structure

Every goal prompt this skill produces has these sections, in this order, with these headings.

### Objective

One paragraph. What the receiving session must accomplish and why it matters, in plain language. Not a step list — the outcome.

### Definition of done

A checklist of verifiable statements. Each line is something an observer can confirm true or false by looking at the repo, running a command, or reading output — never a vague aspiration. "All tests in `tests/auth/` pass" is verifiable; "auth is solid" is not.

### Repo constraints

Two explicit lists: the files and areas that may be modified, and the files and areas that must NOT be touched. Name paths exactly. When other lanes or worktrees own parts of the repo, the must-not list is what keeps the receiving session inside its lane.

### Verification gates

The exact commands the receiving session runs before claiming completion, each with its expected result. Copy-pasteable commands, not descriptions of commands. State what passing looks like (exit code, output, count) so the session can tell pass from fail without judgment.

### Stop conditions

The situations where the receiving session must halt and ask rather than improvise: a verification gate that cannot be made to pass, a constraint that blocks the objective, a required decision the prompt does not answer, anything destructive or irreversible. Name them so the session knows the difference between a problem to solve and a problem to escalate.

## Steps

### Step 1 — Gather the source material

Read the implementation plan, task description, or design doc the prompt will be built from. Resolve every relative reference into an exact repo path. If the source assumes context the receiving session will not have, capture that context now. Completion: you have the objective and all background facts in hand, with real paths.

### Step 2 — Write the objective and definition of done

State the objective in one paragraph. Then write the definition of done as a checklist where every line is independently verifiable. If a line cannot be checked by command or inspection, rewrite it until it can or cut it. Completion: an objective paragraph and a checklist of only-verifiable statements.

### Step 3 — Write the repo constraints

List the files and areas that may be modified and, separately, the files and areas that must not be touched. Use exact paths. When in doubt about an area, put it on the must-not list; the receiving session can ask. Completion: two path lists, may-modify and must-not-touch.

### Step 4 — Write the verification gates

Write the exact commands the receiving session runs to prove the work is done, each with its expected result. These must cover the definition of done — every done-line should map to a gate or an inspection step. Completion: copy-pasteable commands with stated pass criteria that cover the definition of done.

### Step 5 — Write the stop conditions

Name the situations where the session halts and asks instead of improvising. Cover at least: a gate that will not pass, a constraint that blocks the objective, a missing decision, and anything irreversible. Completion: an explicit stop-condition list.

### Step 6 — Run the self-containment and verifiability check

Read the finished prompt as if you are a competent agent with zero context. Ask the two questions: could that agent execute this without our conversation, and could the user verify the result without re-deriving the plan? If either answer is no, find what is missing — an unstated path, an assumed fact, an unverifiable done-line — and fix it. Completion: both questions answer yes.

### Step 7 — Deliver

Hand the user the finished goal prompt as a single self-contained block they can paste into another session. Completion: the prompt is delivered as one block.

## Guardrails

- Never write a definition-of-done line that cannot be checked by command or inspection; an unverifiable done-line means the work can never be honestly called done.
- Never rely on conversation context the receiving session will not have; every path, fact, and assumption the work needs lives inside the prompt or it does not exist.
- Never deliver a prompt without stop conditions; a session that cannot tell a solvable problem from an escalation will improvise past the point where it should have asked.

## Output contract

A single self-contained goal prompt with five sections in order — Objective (one paragraph), Definition of done (verifiable checklist), Repo constraints (may-modify and must-not-touch path lists), Verification gates (exact commands with expected results covering the definition of done), and Stop conditions — delivered as one pasteable block, with no dependency on the originating conversation.

## Verification standard

Do not call the task done until: every definition-of-done line is verifiable by command or inspection, every may-modify and must-not-touch path is exact, every verification gate is a copy-pasteable command with a stated pass criterion and the gates cover the definition of done, stop conditions are present, and the self-containment check in Step 6 answers yes to both questions. Acceptance test: package the next real task the user describes into a goal prompt and confirm it would survive being pasted into a fresh session.
