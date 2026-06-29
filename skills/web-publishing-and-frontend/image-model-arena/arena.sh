#!/usr/bin/env bash
# image-model-arena: build image-model comparison pages from a single config.
#
# Composes image-gateway for generation. It never calls an image API directly
# and never handles API keys. Publishing is a separate step through
# site-publisher (see SKILL.md); this script generates, optimizes, and builds.
#
# Usage:
#   arena.sh generate CONFIG [--subset m1,m2] [--only p1,p2]   # generate missing images
#   arena.sh build    CONFIG [--subset m1,m2] [--only p1,p2]   # optimize + build pages
#   arena.sh all      CONFIG [--subset m1,m2] [--only p1,p2]   # generate then build
#
# --subset limits to listed model ids; --only limits to listed prompt ids.
# Generation skips any image that already exists, so adding one model never
# redoes the others.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATEWAY="$SCRIPT_DIR/../../core-infrastructure/image-gateway/generate.sh"
MAX_W=1200   # optimize: cap displayed image width for the web

command -v jq >/dev/null 2>&1 || { echo "error: missing dependency: jq" >&2; exit 1; }

CMD="${1:-}"; shift || true
CONFIG="${1:-}"; shift || true
SUBSET=""; ONLY=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --subset) SUBSET="${2:-}"; shift 2;;
    --only)   ONLY="${2:-}";   shift 2;;
    *) echo "unknown argument: $1" >&2; exit 1;;
  esac
done

if [[ -z "$CMD" || -z "$CONFIG" || ! -f "$CONFIG" ]]; then
  echo "usage: arena.sh {generate|build|all} CONFIG [--subset m1,m2] [--only p1,p2]" >&2
  exit 1
fi
jq -e . "$CONFIG" >/dev/null 2>&1 || { echo "error: $CONFIG is not valid JSON" >&2; exit 1; }

# --- resolve config fields ---
OUT_DIR=$(jq -r '.output_dir' "$CONFIG")
OUT_DIR="${OUT_DIR/#\~/$HOME}"
IMG_DIR="$OUT_DIR/images"
PAGES_DIR="$OUT_DIR/pages"
REGISTRY="$OUT_DIR/registry.json"
mkdir -p "$IMG_DIR" "$PAGES_DIR"
[[ -f "$REGISTRY" ]] || echo '{"models":{}}' > "$REGISTRY"

in_csv() { # in_csv NEEDLE CSV  -> 0 if NEEDLE listed (or CSV empty)
  local needle="$1" csv="$2"
  [[ -z "$csv" ]] && return 0
  local IFS=','; for x in $csv; do [[ "$x" == "$needle" ]] && return 0; done
  return 1
}

slug() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' \
  | sed 's/-\{2,\}/-/g; s/^-//; s/-$//'; }

# --- generation: one image per (model, prompt), skip-existing ---
generate() {
  if [[ ! -f "$GATEWAY" ]]; then
    echo "error: image-gateway not found at $GATEWAY; install it first." >&2; exit 1
  fi
  local mcount pcount
  mcount=$(jq '.models | length' "$CONFIG")
  pcount=$(jq '.prompts | length' "$CONFIG")
  for ((mi=0; mi<mcount; mi++)); do
    local mid gmodel
    mid=$(jq -r ".models[$mi].id" "$CONFIG")
    gmodel=$(jq -r ".models[$mi].gateway_model" "$CONFIG")
    in_csv "$mid" "$SUBSET" || continue
    mkdir -p "$IMG_DIR/$mid"
    for ((pi=0; pi<pcount; pi++)); do
      local pid ptext out
      pid=$(jq -r ".prompts[$pi].id" "$CONFIG")
      ptext=$(jq -r ".prompts[$pi].text" "$CONFIG")
      in_csv "$pid" "$ONLY" || continue
      out="$IMG_DIR/$mid/$pid.png"
      if [[ -s "$out" ]]; then
        echo "skip (exists): $mid/$pid"
        continue
      fi
      echo "generate: $mid/$pid"
      # image-gateway reads the key from the env file and fails cleanly if absent.
      local log
      log=$(IMAGE_GATEWAY_MODEL="$gmodel" bash "$GATEWAY" "$ptext" --out "$out" 2>&1) || {
        echo "$log" >&2
        echo "error: generation failed for $mid/$pid" >&2; exit 1
      }
      # record per-image cost into the registry if image-gateway printed one
      local cost
      cost=$(printf '%s\n' "$log" | sed -n 's/^cost:[[:space:]]*\$//p' | tail -1)
      [[ -z "$cost" ]] && cost="null"
      local tmp; tmp=$(mktemp)
      jq --arg m "$mid" --arg p "$pid" --arg c "$cost" \
        '.models[$m] = (.models[$m] // {cost_per_image:{}, notes:""}) | .models[$m].cost_per_image[$p] = ($c|tonumber? // null)' \
        "$REGISTRY" > "$tmp" && mv "$tmp" "$REGISTRY"
    done
  done
}

# --- optimize: cap width to MAX_W for the web (originals kept under images/) ---
optimize_one() {
  local src="$1" dst="$2"
  if command -v magick >/dev/null 2>&1; then
    magick "$src" -resize "${MAX_W}x${MAX_W}>" -strip "$dst"
  elif command -v convert >/dev/null 2>&1; then
    convert "$src" -resize "${MAX_W}x${MAX_W}>" -strip "$dst"
  elif command -v sips >/dev/null 2>&1; then
    cp "$src" "$dst"; sips --resampleWidth "$MAX_W" "$dst" >/dev/null 2>&1 || true
  else
    cp "$src" "$dst"
  fi
}

html_head() { # html_head TITLE
  cat <<EOF
<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>$1</title>
<style>
:root{--bg:#0f0f10;--surface:#191919;--text:#f2f0ec;--muted:#9a958c;--border:#2a2a2a;--accent:#e8915b}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);
font:16px/1.5 ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,sans-serif}
.wrap{max-width:72rem;margin:0 auto;padding:48px 24px}
h1{font-size:2rem;letter-spacing:-.01em;margin:0 0 8px}.sub{color:var(--muted);margin:0 0 32px}
table{border-collapse:collapse;width:100%}th,td{border:1px solid var(--border);padding:12px;vertical-align:top;text-align:left}
th{font-size:.8rem;text-transform:uppercase;letter-spacing:.06em;color:var(--muted);background:var(--surface)}
td img{display:block;width:100%;height:auto;border-radius:6px}
.prompt{font-size:.85rem;color:var(--muted);max-width:18rem}
.card{background:var(--surface);border:1px solid var(--border);border-radius:8px;padding:16px;margin-bottom:24px}
.grid{display:grid;gap:16px;grid-template-columns:repeat(auto-fill,minmax(260px,1fr))}
a{color:var(--accent)}
</style></head><body><div class="wrap">
EOF
}

# --- build: optimize images, write per-model pages + shared viewer ---
build() {
  local arena title desc
  arena=$(jq -r '.arena' "$CONFIG")
  title=$(jq -r '.page.title // .arena' "$CONFIG")
  desc=$(jq -r '.page.description // ""' "$CONFIG")
  local mcount pcount
  mcount=$(jq '.models | length' "$CONFIG")
  pcount=$(jq '.prompts | length' "$CONFIG")

  # optimize every existing source image into pages/img/<model>/<prompt>.png
  mkdir -p "$PAGES_DIR/img"
  for ((mi=0; mi<mcount; mi++)); do
    local mid; mid=$(jq -r ".models[$mi].id" "$CONFIG")
    in_csv "$mid" "$SUBSET" || continue
    mkdir -p "$PAGES_DIR/img/$mid"
    for ((pi=0; pi<pcount; pi++)); do
      local pid; pid=$(jq -r ".prompts[$pi].id" "$CONFIG")
      in_csv "$pid" "$ONLY" || continue
      local src="$IMG_DIR/$mid/$pid.png"
      [[ -s "$src" ]] && optimize_one "$src" "$PAGES_DIR/img/$mid/$pid.png"
    done
  done

  # per-model review page
  for ((mi=0; mi<mcount; mi++)); do
    local mid mlabel; mid=$(jq -r ".models[$mi].id" "$CONFIG"); mlabel=$(jq -r ".models[$mi].label // .models[$mi].id" "$CONFIG")
    in_csv "$mid" "$SUBSET" || continue
    local page="$PAGES_DIR/$mid.html"
    { html_head "$mlabel — $title"
      echo "<h1>$mlabel</h1><p class=\"sub\">$desc</p><div class=\"grid\">"
      for ((pi=0; pi<pcount; pi++)); do
        local pid ptext; pid=$(jq -r ".prompts[$pi].id" "$CONFIG"); ptext=$(jq -r ".prompts[$pi].text" "$CONFIG")
        in_csv "$pid" "$ONLY" || continue
        if [[ -s "$PAGES_DIR/img/$mid/$pid.png" ]]; then
          echo "<div class=\"card\"><img src=\"img/$mid/$pid.png\" alt=\"$pid\"><p class=\"prompt\">$ptext</p></div>"
        fi
      done
      echo "</div><p class=\"sub\"><a href=\"index.html\">← side-by-side viewer</a></p></div></body></html>"
    } > "$page"
    echo "built: $page"
  done

  # shared side-by-side viewer: rows = prompts, columns = models
  local viewer="$PAGES_DIR/index.html"
  { html_head "$title"
    echo "<h1>$title</h1><p class=\"sub\">$desc</p><table><thead><tr><th>Prompt</th>"
    for ((mi=0; mi<mcount; mi++)); do
      local mid mlabel; mid=$(jq -r ".models[$mi].id" "$CONFIG"); mlabel=$(jq -r ".models[$mi].label // .models[$mi].id" "$CONFIG")
      in_csv "$mid" "$SUBSET" || continue
      echo "<th><a href=\"$mid.html\">$mlabel</a></th>"
    done
    echo "</tr></thead><tbody>"
    for ((pi=0; pi<pcount; pi++)); do
      local pid ptext; pid=$(jq -r ".prompts[$pi].id" "$CONFIG"); ptext=$(jq -r ".prompts[$pi].text" "$CONFIG")
      in_csv "$pid" "$ONLY" || continue
      echo "<tr><td class=\"prompt\">$ptext</td>"
      for ((mi=0; mi<mcount; mi++)); do
        local mid; mid=$(jq -r ".models[$mi].id" "$CONFIG")
        in_csv "$mid" "$SUBSET" || continue
        if [[ -s "$PAGES_DIR/img/$mid/$pid.png" ]]; then
          echo "<td><img src=\"img/$mid/$pid.png\" alt=\"$mid $pid\"></td>"
        else
          echo "<td class=\"prompt\">—</td>"
        fi
      done
      echo "</tr>"
    done
    echo "</tbody></table></div></body></html>"
  } > "$viewer"
  echo "built: $viewer"
  echo "registry: $REGISTRY"
}

case "$CMD" in
  generate) generate;;
  build)    build;;
  all)      generate; build;;
  *) echo "usage: arena.sh {generate|build|all} CONFIG [--subset m1,m2] [--only p1,p2]" >&2; exit 1;;
esac
