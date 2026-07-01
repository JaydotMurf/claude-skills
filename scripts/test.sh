#!/usr/bin/env bash
# test.sh: Tier 1 of the quality-test system — deterministic, offline behavioral
# tests for every script-bearing skill. No API keys, no network, no spend, so it
# runs on the same CI gate as scripts/check.sh.
#
# What it covers:
#   - the Python selftests (radio-edit, nle-assistant) that assert pure logic
#   - "clean no-key failure": key-guarded scripts exit non-zero with a helpful
#     message when no key is present (run in a scrubbed env)
#   - "usage / arg validation": scripts reject missing or malformed arguments
#     before doing any real work
#   - HTML offline-safety: html-artifacts/check.sh passes a self-contained file
#     and fails one with an external reference
#
# Usage: scripts/test.sh        (exit 0 = all green)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

pass=0; fail=0
green() { printf '  ok   %s\n' "$1"; pass=$((pass+1)); }
red()   { printf '  FAIL %s\n' "$1"; [[ -n "${2:-}" ]] && printf '       %s\n' "$2"; fail=$((fail+1)); }

# run a command in a scrubbed env (no leaked API keys); capture combined output.
# usage: run_scrubbed ENVFILE -- cmd args...   -> sets $RC and $OUT
run_scrubbed() {
  local envfile="$1"; shift; [[ "$1" == "--" ]] && shift
  OUT="$(env -i PATH="$PATH" HOME="$HOME" AGENT_SKILLS_ENV="$envfile" "$@" 2>&1)"
  RC=$?
}

# assert a command fails (non-zero) and its output contains a substring.
expect_fail_contains() { # label envfile substr -- cmd...
  local label="$1" envfile="$2" substr="$3"; shift 3; [[ "$1" == "--" ]] && shift
  run_scrubbed "$envfile" -- "$@"
  if [[ $RC -ne 0 && "$OUT" == *"$substr"* ]]; then green "$label"
  else red "$label" "rc=$RC, wanted non-zero and output containing: $substr"; fi
}

# assert a command succeeds (zero).
expect_ok() { # label envfile -- cmd...
  local label="$1" envfile="$2"; shift 2; [[ "$1" == "--" ]] && shift
  run_scrubbed "$envfile" -- "$@"
  if [[ $RC -eq 0 ]]; then green "$label"; else red "$label" "rc=$RC: $OUT"; fi
}

# a dummy env file so arg-validation paths run without a real key (and never
# reach the network, because we deliberately pass invalid/missing arguments).
DUMMY_ENV="$(mktemp)"
cat > "$DUMMY_ENV" <<'EOF'
OPENROUTER_API_KEY=dummy
PERPLEXITY_API_KEY=dummy
ASSEMBLYAI_API_KEY=dummy
RESEND_API_KEY=dummy
STAKEHOLDER_UPDATE_EMAIL_FROM=onboarding@resend.dev
EOF
trap 'rm -f "$DUMMY_ENV" "$GOOD_HTML" "$BAD_HTML"' EXIT

echo "== Python selftests =="
expect_ok "radio-edit selftest" /dev/null -- python3 skills/video-and-media-production/radio-edit/radio-edit.py selftest
expect_ok "nle-assistant selftest" /dev/null -- python3 skills/video-and-media-production/nle-assistant/nle.py selftest

echo "== clean no-key failure (scrubbed env, /dev/null env file) =="
expect_fail_contains "current-info-search no key"   /dev/null "no API key" -- bash skills/core-infrastructure/current-info-search/search.sh "q"
expect_fail_contains "image-gateway no key"         /dev/null "no API key" -- bash skills/core-infrastructure/image-gateway/generate.sh "p"
expect_fail_contains "media-transcription no key"   /dev/null "no API key" -- bash skills/core-infrastructure/media-transcription/transcribe.sh /tmp/x.m4a
expect_fail_contains "stakeholder-email no key"     /dev/null "no API key" -- bash skills/agent-operations/stakeholder-update-email/send-update.sh --to a@b.com --subject S --text /tmp/x

echo "== usage / arg validation (dummy key present, no network reached) =="
expect_fail_contains "search usage (no question)"   "$DUMMY_ENV" "usage"   -- bash skills/core-infrastructure/current-info-search/search.sh
expect_fail_contains "generate usage (no prompt)"   "$DUMMY_ENV" "usage"   -- bash skills/core-infrastructure/image-gateway/generate.sh
expect_fail_contains "transcribe usage (no media)"  "$DUMMY_ENV" "usage"   -- bash skills/core-infrastructure/media-transcription/transcribe.sh
expect_fail_contains "send-update usage (no args)"  "$DUMMY_ENV" "usage"   -- bash skills/agent-operations/stakeholder-update-email/send-update.sh
expect_fail_contains "arena usage (no config)"      "$DUMMY_ENV" "usage"   -- bash skills/web-publishing-and-frontend/image-model-arena/arena.sh
expect_fail_contains "gallery usage (no spec)"      "$DUMMY_ENV" "usage"   -- bash skills/web-publishing-and-frontend/essay-illustration-gallery/build-gallery.sh
expect_fail_contains "arena bad JSON config"        "$DUMMY_ENV" "not valid JSON" -- bash skills/web-publishing-and-frontend/image-model-arena/arena.sh all /etc/hosts

echo "== HTML offline-safety (html-artifacts/check.sh) =="
GOOD_HTML="$(mktemp --suffix=.html 2>/dev/null || mktemp -t good.XXXX.html)"
BAD_HTML="$(mktemp --suffix=.html 2>/dev/null || mktemp -t bad.XXXX.html)"
cat > "$GOOD_HTML" <<'EOF'
<!DOCTYPE html><html><head><meta charset="utf-8"><style>body{color:#111}</style></head>
<body><h1>Self-contained</h1><p>No external references here.</p></body></html>
EOF
cat > "$BAD_HTML" <<'EOF'
<!DOCTYPE html><html><head><script src="https://cdn.example.com/app.js"></script></head>
<body><h1>Has an external script</h1></body></html>
EOF
expect_ok            "check.sh passes self-contained HTML" /dev/null -- bash skills/core-infrastructure/html-artifacts/check.sh "$GOOD_HTML"
expect_fail_contains "check.sh fails external-ref HTML"    /dev/null "" -- bash skills/core-infrastructure/html-artifacts/check.sh "$BAD_HTML"

echo
echo "passed: $pass   failed: $fail"
[[ $fail -eq 0 ]] || { echo "TESTS FAILED"; exit 1; }
echo "ALL GREEN"
