#!/usr/bin/env bash
# image-gateway: generate or edit an image via OpenRouter (Gemini 2.5 Flash Image).
#
# Usage:
#   generate.sh "a photorealistic street at dusk"
#   generate.sh "make the sky purple" --edit input.png
#   generate.sh "a square logo" --aspect 1:1 --out logo.png
#
# The API key is read from the env file, never passed on the command line.
# Resolution order: IMAGE_GATEWAY_API_KEY, then OPENROUTER_API_KEY.

set -euo pipefail

ENV_FILE="${AGENT_SKILLS_ENV:-$HOME/.config/agent-skills/.env}"
MODEL="${IMAGE_GATEWAY_MODEL:-google/gemini-2.5-flash-image}"   # Nano Banana default; override with IMAGE_GATEWAY_MODEL
OUTPUT_DIR="${IMAGE_GATEWAY_OUTPUT_DIR:-$HOME/Pictures/agent-images}"

# --- dependencies ---
for bin in curl jq openssl; do
  command -v "$bin" >/dev/null 2>&1 || { echo "error: missing dependency: $bin" >&2; exit 1; }
done

# --- load secrets from the env file (values stay out of the command line) ---
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi
API_KEY="${IMAGE_GATEWAY_API_KEY:-${OPENROUTER_API_KEY:-}}"
if [[ -z "$API_KEY" ]]; then
  echo "error: no API key found. Add OPENROUTER_API_KEY (or IMAGE_GATEWAY_API_KEY) to $ENV_FILE" >&2
  exit 1
fi

# --- parse args ---
PROMPT="${1:-}"; shift || true
ASPECT=""; OUT=""; EDIT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --aspect) ASPECT="${2:-}"; shift 2;;
    --out)    OUT="${2:-}";    shift 2;;
    --edit)   EDIT="${2:-}";   shift 2;;
    *) echo "unknown argument: $1" >&2; exit 1;;
  esac
done
if [[ -z "$PROMPT" ]]; then
  echo "usage: generate.sh \"prompt\" [--edit image] [--aspect 16:9] [--out name.png]" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# --- build the user message content ---
content=$(jq -n --arg t "$PROMPT" '[{type:"text", text:$t}]')
if [[ -n "$EDIT" ]]; then
  [[ -f "$EDIT" ]] || { echo "error: edit image not found: $EDIT" >&2; exit 1; }
  mime=$(file --mime-type -b "$EDIT")
  b64in=$(openssl base64 -A -in "$EDIT")
  content=$(jq -n --argjson c "$content" --arg url "data:$mime;base64,$b64in" \
    '$c + [{type:"image_url", image_url:{url:$url}}]')
fi

# --- build the request body ---
body=$(jq -n --arg m "$MODEL" --argjson content "$content" \
  '{model:$m, modalities:["image","text"], messages:[{role:"user", content:$content}]}')
if [[ -n "$ASPECT" ]]; then
  body=$(jq --arg a "$ASPECT" '. + {image_config:{aspect_ratio:$a}}' <<<"$body")
fi

# --- call the API ---
resp=$(curl -sS https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$body")

# --- extract the base64 image, tolerant of the known response shapes ---
img=$(jq -r '
  [ .choices[0].message.images[0].image_url.url?,
    (.choices[0].message.content[]? | select(.type=="image_url") | .image_url.url?),
    .data[0].b64_json?
  ] | map(select(. != null and . != "")) | (.[0] // "")' <<<"$resp")

if [[ -z "$img" ]]; then
  echo "error: no image in response. Raw response:" >&2
  jq '.' <<<"$resp" >&2 2>/dev/null || echo "$resp" >&2
  exit 1
fi

# strip a data-URL prefix if one is present, then decode
b64data="${img#data:*;base64,}"

# --- filename: date-prefixed slug under the output dir ---
slug=$(printf '%s' "$PROMPT" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' \
  | sed 's/-\{2,\}/-/g; s/^-//; s/-$//' | cut -c1-40)
[[ -z "$OUT" ]] && OUT="$(date +%Y-%m-%d)-${slug:-image}.png"
[[ "$OUT" != /* ]] && OUT="$OUTPUT_DIR/$OUT"

printf '%s' "$b64data" | openssl base64 -d -A > "$OUT"

cost=$(jq -r '.usage.cost // "n/a"' <<<"$resp")
echo "saved: $OUT"
echo "cost:  \$$cost"
