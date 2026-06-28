#!/usr/bin/env bash
# current-info-search: answer fast-moving questions via the Perplexity API,
# grounded in live web search with dated sources.
#
# Usage:
#   search.sh "what shipped this month for X?"
#   search.sh "current price of Y" --recency week
#   search.sh "a harder, multi-part question" --model sonar-pro
#
# The API key is read from the env file, never passed on the command line.
# Resolution order: CURRENT_INFO_SEARCH_API_KEY, then PERPLEXITY_API_KEY.

set -euo pipefail

ENV_FILE="${AGENT_SKILLS_ENV:-$HOME/.config/agent-skills/.env}"
MODEL_DEFAULT="${CURRENT_INFO_SEARCH_MODEL:-sonar}"
ENDPOINT="https://api.perplexity.ai/v1/sonar"   # legacy fallback: https://api.perplexity.ai/chat/completions

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
API_KEY="${CURRENT_INFO_SEARCH_API_KEY:-${PERPLEXITY_API_KEY:-}}"
if [[ -z "$API_KEY" ]]; then
  echo "error: no API key found. Add PERPLEXITY_API_KEY (or CURRENT_INFO_SEARCH_API_KEY) to $ENV_FILE" >&2
  exit 1
fi

# --- parse args ---
QUESTION="${1:-}"; shift || true
MODEL="$MODEL_DEFAULT"; RECENCY=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --model)   MODEL="${2:-}";   shift 2;;
    --recency) RECENCY="${2:-}"; shift 2;;
    *) echo "unknown argument: $1" >&2; exit 1;;
  esac
done
if [[ -z "$QUESTION" ]]; then
  echo "usage: search.sh \"question\" [--recency hour|day|week|month|year] [--model sonar-pro]" >&2
  exit 1
fi

SYSTEM="You are a current-information search assistant. Answer using the live web search results. For each key claim, cite the publication date and link the primary source. Separate confirmed facts from inference. When the search results conflict with prior knowledge, the search results win."

# --- build request body ---
body=$(jq -n --arg m "$MODEL" --arg sys "$SYSTEM" --arg q "$QUESTION" \
  '{model:$m, messages:[{role:"system",content:$sys},{role:"user",content:$q}]}')
if [[ -n "$RECENCY" ]]; then
  body=$(jq --arg r "$RECENCY" '. + {search_recency_filter:$r}' <<<"$body")
fi

# --- call the API ---
resp=$(curl -sS "$ENDPOINT" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$body")

answer=$(jq -r '.choices[0].message.content // ""' <<<"$resp")
if [[ -z "$answer" ]]; then
  echo "error: no answer in response. Raw response:" >&2
  jq '.' <<<"$resp" >&2 2>/dev/null || echo "$resp" >&2
  exit 1
fi

echo "$answer"
echo
echo "Sources:"
sources=$(jq -r '
  if (.search_results | type) == "array" and (.search_results | length) > 0 then
    .search_results[] | "- \(.title // .url) — \(.url) (\(.date // "n/a"))"
  elif (.citations | type) == "array" then
    .citations[] | "- \(.)"
  else empty end' <<<"$resp")
[[ -n "$sources" ]] && echo "$sources" || echo "- (none returned)"

echo
jq -r '.usage | "tokens: \(.total_tokens // "n/a")  model: '"$MODEL"'"' <<<"$resp"
