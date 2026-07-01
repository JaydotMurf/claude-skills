---
name: stakeholder-update-email
description: After work ships with stakeholder-visible impact, write and (on explicit confirmation) send a short, truthful update email in the recipient's vocabulary. Gates on whether anything stakeholder-visible actually changed, never claims unverified work as done, and follows a fixed what-changed / what-it-means / what's-next format. Sends via the Resend API or drafts for review per the user's preference. Trigger when work merges or ships with visible impact for a stakeholder, or when the user asks for an update email.
tags: [agent-operations, communication, email, resend]
audience: DoD contractors, veterans, solo operators
source: open-skills
---

# Stakeholder Update Email

When something ships that a stakeholder will notice, the right follow-up is a short, honest note in their language — not silence, and not a changelog dump. This skill writes that note, gates on whether there is anything worth sending, and either drafts it for review or sends it via Resend once the user confirms.

## Configuration and preferences

The build prompt asks for an interview: recurring stakeholders and what each cares about, send-directly versus always-draft, and whether the user is CC'd on sends. No interview was possible at build time, so these are recorded assumptions to confirm on first real use:

- Stakeholder roster: none captured yet. On first run, ask who the recurring stakeholders are and what each cares about, then store them in `~/.config/agent-skills/stakeholder-update-email.json` so the roster is read on later runs rather than re-asked.
- Send versus draft: always draft for review by default. Sending happens only after the user's explicit confirmation on that specific message — the safer default for outbound stakeholder mail.
- CC: CC the user on every send by default.

Sending uses the Resend API via `send-update.sh`. The API key is read from `~/.config/agent-skills/.env` (`STAKEHOLDER_UPDATE_EMAIL_API_KEY`, falling back to `RESEND_API_KEY`); the sender address comes from `STAKEHOLDER_UPDATE_EMAIL_FROM`. No key or address is ever written into a skill file or passed on the command line.

## When to use this skill

Invoke it when:

- Work merges or ships and the change has visible impact for a stakeholder.
- The user explicitly asks for a stakeholder update email about something that shipped.

Do not invoke it for internal-only changes nobody outside the work will notice, for routine progress that has not shipped, or as an automatic send on every merge — drafting is fine to offer, but sending is never automatic and never without confirmation. If nothing stakeholder-visible changed, the right action is to say so and send nothing.

## Steps

### Step 1 — Gate: did anything stakeholder-visible change?

Decide whether the work actually changed something a stakeholder would notice — behavior, availability, a deliverable, a date. If not, say so plainly and send nothing. This gate runs first; a quiet "nothing here warrants an email" is a valid and common outcome. Completion: a yes/no on stakeholder-visible impact, and if no, a stop.

### Step 2 — Pick the recipient and load what they care about

Identify the right stakeholder for this change and what they care about, from the stored roster or by asking. Address the email to the person the change actually affects, not a blast list. Completion: a named recipient and their concern in hand.

### Step 3 — Write in the recipient's vocabulary, only what was verified

Describe the shipped behavior in the recipient's terms, not implementation detail — what they can now do or see, not which functions changed. Never call anything done that was not verified; if you cannot confirm it works, do not claim it does. If the work shipped partially, say exactly which part shipped and which did not. Completion: a draft that speaks the recipient's language and claims only verified, accurately-scoped outcomes.

### Step 4 — Use the fixed short format

Structure the email in three short parts: what changed, what it means for them, what's next. Keep it short — a stakeholder reads the first two lines and the subject. Completion: a draft in the what-changed / what-it-means / what's-next format.

### Step 5 — Draft or send per preference, with confirmation before any send

Present the draft to the user. If the preference is draft-only, stop here and hand over the draft. If sending, show the user the exact recipient, CC, subject, and body and get explicit confirmation for this specific message before calling `send-update.sh`. CC the user per preference. Completion: either a delivered draft, or a confirmed send with a returned message id.

## Sending

```bash
./send-update.sh --to "stakeholder@example.com" --subject "Subject line" \
  --html update.html --cc "user@example.com"
```

`send-update.sh` reads the Resend key and sender from the env file, posts to the Resend API, and prints the returned message id. It exits with a clear error if the key or sender is missing, so a misconfiguration fails loudly instead of silently not sending.

## Guardrails

- Never send without the user's explicit confirmation on that specific message; drafting is allowed freely, sending is not.
- Never send an email when nothing stakeholder-visible changed; the Step 1 gate produces a quiet "nothing to send," not a manufactured update.
- Never claim work is done that was not verified, and never describe a partial ship as complete; name which part shipped.
- Never put the Resend API key or sender address in a skill file or on the command line; both come from the env file.

## Output contract

Either a stated "nothing stakeholder-visible changed, nothing sent," or a short update email to the right recipient — in their vocabulary, claiming only verified and accurately-scoped outcomes, in the what-changed / what-it-means / what's-next format — delivered as a draft for review, or sent via Resend (with the user CC'd) only after explicit per-message confirmation, returning the message id.

## Verification standard

Do not call the task done until: the Step 1 gate was applied (visible change confirmed, or nothing sent), the email speaks the recipient's vocabulary and claims only verified outcomes with partial ships named, it follows the three-part format, and any send happened only after explicit confirmation and returned a message id. Script checks done at build time (2026-06-29): `bash -n` passes, the recipient-list and body jq build the exact verified Resend body shape `{from,to[],subject,html,cc[],reply_to}`, and the script exits cleanly with a clear message when the API key is absent. Acceptance test: draft an update for the most recent thing the user shipped. Live-validated 2026-07-01: a real three-part HTML update sent via the Resend sandbox sender (`from onboarding@resend.dev`) returned message id `bf82e792-1733-48a3-bf9a-ab135b8622d2`; the same run added and exercised `--reply-to`, which the header comment had claimed but the code did not previously send. Sandbox note: the `onboarding@resend.dev` sender only delivers to the Resend account's own email until a custom domain is verified.
