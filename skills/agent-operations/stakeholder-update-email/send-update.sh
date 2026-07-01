#!/usr/bin/env bash
# stakeholder-update-email: send a stakeholder update email via the Resend API.
#
# Usage:
#   send-update.sh --to dst@example.com --subject "Subject" --html update.html
#   send-update.sh --to "a@x.com,b@x.com" --subject "S" --text update.txt --cc me@x.com
#   send-update.sh --to dst@example.com --subject "S" --html u.html --reply-to me@proton.me
#
# The API key is read from the env file, never passed on the command line.
# Resolution order: STAKEHOLDER_UPDATE_EMAIL_API_KEY, then RESEND_API_KEY.
# Verified API shape (2026-06-29): POST https://api.resend.com/emails,
# Bearer auth, JSON body {from,to[],subject,html|text,cc[],reply_to}, response {id}.

set -euo pipefail

ENV_FILE="${AGENT_SKILLS_ENV:-$HOME/.config/agent-skills/.env}"
ENDPOINT="https://api.resend.com/emails"
FROM_DEFAULT="${STAKEHOLDER_UPDATE_EMAIL_FROM:-}"

for bin in curl jq; do
  command -v "$bin" >/dev/null 2>&1 || { echo "error: missing dependency: $bin" >&2; exit 1; }
done

# --- load secrets from the env file ---
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi
API_KEY="${STAKEHOLDER_UPDATE_EMAIL_API_KEY:-${RESEND_API_KEY:-}}"
if [[ -z "$API_KEY" ]]; then
  echo "error: no API key found. Add RESEND_API_KEY (or STAKEHOLDER_UPDATE_EMAIL_API_KEY) to $ENV_FILE" >&2
  exit 1
fi

# --- parse args ---
TO=""; CC=""; SUBJECT=""; HTML_FILE=""; TEXT_FILE=""; FROM="$FROM_DEFAULT"; REPLY_TO="${STAKEHOLDER_UPDATE_EMAIL_REPLY_TO:-}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --to)       TO="${2:-}";        shift 2;;
    --cc)       CC="${2:-}";        shift 2;;
    --subject)  SUBJECT="${2:-}";   shift 2;;
    --html)     HTML_FILE="${2:-}"; shift 2;;
    --text)     TEXT_FILE="${2:-}"; shift 2;;
    --from)     FROM="${2:-}";      shift 2;;
    --reply-to) REPLY_TO="${2:-}";  shift 2;;
    *) echo "unknown argument: $1" >&2; exit 1;;
  esac
done

if [[ -z "$TO" || -z "$SUBJECT" ]]; then
  echo "usage: send-update.sh --to <addr[,addr]> --subject <s> (--html <file> | --text <file>) [--cc <addr[,addr]>] [--from <addr>] [--reply-to <addr>]" >&2
  exit 1
fi
if [[ -z "$HTML_FILE" && -z "$TEXT_FILE" ]]; then
  echo "error: provide --html <file> or --text <file>" >&2
  exit 1
fi
if [[ -z "$FROM" ]]; then
  echo "error: no sender. Set STAKEHOLDER_UPDATE_EMAIL_FROM in $ENV_FILE or pass --from" >&2
  exit 1
fi

# --- helper: split a comma list into a JSON array ---
to_json_array() {
  local IFS=','; read -ra parts <<<"$1"
  printf '%s\n' "${parts[@]}" | jq -R . | jq -s 'map(select(length>0) | gsub("^\\s+|\\s+$";""))'
}

# --- build request body ---
body=$(jq -n --arg from "$FROM" --arg subject "$SUBJECT" \
  --argjson to "$(to_json_array "$TO")" \
  '{from:$from, to:$to, subject:$subject}')

if [[ -n "$HTML_FILE" ]]; then
  [[ -f "$HTML_FILE" ]] || { echo "error: html file not found: $HTML_FILE" >&2; exit 1; }
  body=$(jq --rawfile html "$HTML_FILE" '. + {html:$html}' <<<"$body")
fi
if [[ -n "$TEXT_FILE" ]]; then
  [[ -f "$TEXT_FILE" ]] || { echo "error: text file not found: $TEXT_FILE" >&2; exit 1; }
  body=$(jq --rawfile text "$TEXT_FILE" '. + {text:$text}' <<<"$body")
fi
if [[ -n "$CC" ]]; then
  body=$(jq --argjson cc "$(to_json_array "$CC")" '. + {cc:$cc}' <<<"$body")
fi
if [[ -n "$REPLY_TO" ]]; then
  body=$(jq --arg r "$REPLY_TO" '. + {reply_to:$r}' <<<"$body")
fi

# --- call the API ---
resp=$(curl -sS -X POST "$ENDPOINT" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$body")

id=$(jq -r '.id // ""' <<<"$resp")
if [[ -z "$id" ]]; then
  echo "error: send failed, no id in response. Raw response:" >&2
  jq '.' <<<"$resp" >&2 2>/dev/null || echo "$resp" >&2
  exit 1
fi

echo "sent: $id"
