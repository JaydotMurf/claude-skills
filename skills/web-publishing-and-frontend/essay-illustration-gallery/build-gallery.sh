#!/usr/bin/env bash
# essay-illustration-gallery: generate frames and assemble a single self-contained
# gallery page from one spec.
#
# Composes image-gateway for generation. It never calls an image API directly and
# never handles API keys. Images are embedded as base64 so the gallery is one
# self-contained HTML file, per the html-artifacts convention.
#
# Usage:
#   build-gallery.sh generate SPEC   # generate any missing frame images
#   build-gallery.sh assemble SPEC   # build the self-contained gallery HTML
#   build-gallery.sh all      SPEC   # generate then assemble
#
# SPEC is JSON: { essay, style_descriptor, output, frames:[{id,passage,rationale,
# caption,prompt}, ...] }. The style_descriptor is prepended to every frame prompt
# so all frames share one locked style.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATEWAY="$SCRIPT_DIR/../../core-infrastructure/image-gateway/generate.sh"

command -v jq >/dev/null 2>&1 || { echo "error: missing dependency: jq" >&2; exit 1; }
command -v openssl >/dev/null 2>&1 || { echo "error: missing dependency: openssl" >&2; exit 1; }

CMD="${1:-}"; SPEC="${2:-}"
if [[ -z "$CMD" || -z "$SPEC" || ! -f "$SPEC" ]]; then
  echo "usage: build-gallery.sh {generate|assemble|all} SPEC" >&2; exit 1
fi
jq -e . "$SPEC" >/dev/null 2>&1 || { echo "error: $SPEC is not valid JSON" >&2; exit 1; }

ESSAY=$(jq -r '.essay' "$SPEC")
STYLE=$(jq -r '.style_descriptor' "$SPEC")
OUT=$(jq -r '.output' "$SPEC"); OUT="${OUT/#\~/$HOME}"
FRAME_COUNT=$(jq '.frames | length' "$SPEC")
SLUG=$(printf '%s' "$ESSAY" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' | sed 's/-\{2,\}/-/g; s/^-//; s/-$//')
FRAME_DIR="$(dirname "$OUT")/${SLUG}-frames"
mkdir -p "$FRAME_DIR" "$(dirname "$OUT")"

generate() {
  if [[ ! -f "$GATEWAY" ]]; then
    echo "error: image-gateway not found at $GATEWAY; install it first." >&2; exit 1
  fi
  for ((i=0; i<FRAME_COUNT; i++)); do
    local fid prompt img
    fid=$(jq -r ".frames[$i].id" "$SPEC")
    prompt=$(jq -r ".frames[$i].prompt" "$SPEC")
    img="$FRAME_DIR/$fid.png"
    if [[ -s "$img" ]]; then echo "skip (exists): $fid"; continue; fi
    echo "generate: $fid"
    # style descriptor is locked in front of every prompt so all frames match.
    bash "$GATEWAY" "$STYLE. $prompt" --out "$img" || {
      echo "error: generation failed for frame $fid" >&2; exit 1; }
  done
}

# HTML-escape stdin for safe insertion into text nodes.
esc() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }

assemble() {
  local desc
  desc=$(jq -r '.description // ""' "$SPEC")
  {
    cat <<EOF
<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>$(printf '%s' "$ESSAY" | esc) — illustration gallery</title>
<style>
:root{--bg:#faf9f7;--surface:#fff;--text:#1b1a17;--muted:#6b665d;--border:#e7e2d9;--accent:#b4541f;--measure:40rem}
@media (prefers-color-scheme:dark){:root{--bg:#141311;--surface:#1c1b18;--text:#f1efe9;--muted:#a39d92;--border:#2b2925;--accent:#e0915c}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);
font:18px/1.6 ui-serif,Georgia,"Times New Roman",serif}
.wrap{max-width:var(--measure);margin:0 auto;padding:72px 24px}
header{margin-bottom:56px}h1{font-size:2.4rem;line-height:1.1;letter-spacing:-.01em;margin:0 0 12px}
.lede{color:var(--muted);font-size:1.1rem;margin:0}
.style-note{margin-top:20px;font:13px/1.5 ui-monospace,Menlo,monospace;color:var(--muted);
background:var(--surface);border:1px solid var(--border);border-radius:8px;padding:12px 14px}
figure{margin:0 0 56px}figure img{display:block;width:100%;height:auto;border-radius:10px;border:1px solid var(--border)}
figcaption{margin-top:14px}.passage{font-style:italic;color:var(--muted)}
.caption{margin-top:6px;font-size:1rem}.idx{font:12px/1 ui-monospace,Menlo,monospace;color:var(--accent);
text-transform:uppercase;letter-spacing:.08em;display:block;margin-bottom:8px}
</style></head><body><div class="wrap">
<header><h1>$(printf '%s' "$ESSAY" | esc)</h1>
<p class="lede">$(printf '%s' "$desc" | esc)</p>
<div class="style-note">Locked style: $(printf '%s' "$STYLE" | esc)</div></header>
EOF
    for ((i=0; i<FRAME_COUNT; i++)); do
      local fid passage caption rationale img b64 mime
      fid=$(jq -r ".frames[$i].id" "$SPEC")
      passage=$(jq -r ".frames[$i].passage" "$SPEC")
      caption=$(jq -r ".frames[$i].caption" "$SPEC")
      rationale=$(jq -r ".frames[$i].rationale" "$SPEC")
      img="$FRAME_DIR/$fid.png"
      echo "<figure><span class=\"idx\">Frame $((i+1)) of $FRAME_COUNT</span>"
      if [[ -s "$img" ]]; then
        mime=$(file --mime-type -b "$img")
        b64=$(openssl base64 -A -in "$img")
        echo "<img src=\"data:$mime;base64,$b64\" alt=\"$(printf '%s' "$fid" | esc)\">"
      else
        echo "<div class=\"style-note\">[frame not generated yet: $fid]</div>"
      fi
      echo "<figcaption><p class=\"passage\">$(printf '%s' "$passage" | esc)</p>"
      echo "<p class=\"caption\">$(printf '%s' "$caption" | esc)</p>"
      echo "<p class=\"caption\" style=\"color:var(--muted);font-size:.9rem\">Why this moment: $(printf '%s' "$rationale" | esc)</p>"
      echo "</figcaption></figure>"
    done
    echo "</div></body></html>"
  } > "$OUT"
  echo "gallery: $OUT"
}

case "$CMD" in
  generate) generate;;
  assemble) assemble;;
  all)      generate; assemble;;
  *) echo "usage: build-gallery.sh {generate|assemble|all} SPEC" >&2; exit 1;;
esac
