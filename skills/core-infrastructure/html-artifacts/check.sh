#!/usr/bin/env bash
# check.sh: verify an HTML artifact is self-contained and offline-safe, then
# optionally open it to confirm it renders.
#
# Usage:
#   check.sh artifact.html
#   check.sh artifact.html --open      # also open in the default browser
#
# Fails if the file pulls any external resource needed to render (script src,
# stylesheet link, remote image, @import, CDN font). External <a href> links
# are allowed, since they are navigation, not render dependencies.

set -euo pipefail

FILE="${1:-}"; OPEN=false
[[ "${2:-}" == "--open" ]] && OPEN=true
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  echo "usage: check.sh artifact.html [--open]" >&2
  exit 1
fi

fail=0
report() { echo "  FAIL: $1" >&2; fail=1; }

# external rendering dependencies (these break offline use)
grep -Eiq '<script[^>]+src=' "$FILE"                     && report "external <script src=>"
grep -Eiq '<link[^>]+rel=["'"'"']?stylesheet' "$FILE"    && report "external stylesheet <link>"
grep -Eiq '<img[^>]+src=["'"'"']?https?:' "$FILE"        && report "remote <img src=http...>"
grep -Eiq '@import' "$FILE"                              && report "CSS @import"
grep -Eiq 'url\(\s*["'"'"']?https?:' "$FILE"             && report "CSS url(http...)"
grep -Eiq 'src=["'"'"']?//' "$FILE"                      && report "protocol-relative src"

# sanity: an artifact should carry its own inline style
grep -Eiq '<style' "$FILE" || report "no inline <style> block found"

if (( fail )); then
  echo "not self-contained: $FILE" >&2
  exit 1
fi

echo "ok: self-contained and offline-safe: $FILE"

if $OPEN; then
  if command -v open >/dev/null 2>&1; then open "$FILE"
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$FILE"
  else echo "note: no opener found; open $FILE manually to verify rendering." >&2
  fi
fi
