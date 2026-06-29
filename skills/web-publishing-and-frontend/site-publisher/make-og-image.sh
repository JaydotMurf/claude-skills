#!/usr/bin/env bash
# site-publisher: generate a 1200x630 Open Graph image for a page.
#
# It composes the image-gateway skill for generation, then crops/scales the
# result to exactly 1200x630 (the Open Graph standard). It never calls an image
# API directly and never handles API keys — image-gateway owns both.
#
# Usage:
#   make-og-image.sh "PROMPT" [--out og-name.png]
#
# Exit non-zero with a clear message if image-gateway is missing, if generation
# fails (e.g. no API key), or if no image tool (ImageMagick or sips) is available.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATEWAY="$SCRIPT_DIR/../../core-infrastructure/image-gateway/generate.sh"
OG_W=1200
OG_H=630

# --- args ---
PROMPT="${1:-}"; shift || true
OUT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --out) OUT="${2:-}"; shift 2;;
    *) echo "unknown argument: $1" >&2; exit 1;;
  esac
done
if [[ -z "$PROMPT" ]]; then
  echo "usage: make-og-image.sh \"prompt\" [--out og-name.png]" >&2
  exit 1
fi
[[ -z "$OUT" ]] && OUT="og-image.png"

# --- locate the image-gateway skill ---
if [[ ! -x "$GATEWAY" && ! -f "$GATEWAY" ]]; then
  echo "error: image-gateway not found at $GATEWAY. site-publisher generates OG images through image-gateway; install that skill first." >&2
  exit 1
fi

# --- generate via image-gateway (closest aspect to 1200x630 is 16:9) ---
# image-gateway reads the API key from the env file and fails cleanly if absent.
RAW="$(mktemp -t og-raw).png"
trap 'rm -f "$RAW"' EXIT
bash "$GATEWAY" "$PROMPT" --aspect 16:9 --out "$RAW"

if [[ ! -s "$RAW" ]]; then
  echo "error: image-gateway produced no image; see its output above." >&2
  exit 1
fi

# --- crop/scale to exactly 1200x630 (cover, center) ---
crop_with_imagemagick() {
  local bin="$1"
  "$bin" "$RAW" -resize "${OG_W}x${OG_H}^" -gravity center -extent "${OG_W}x${OG_H}" "$OUT"
}

if command -v magick >/dev/null 2>&1; then
  crop_with_imagemagick magick
elif command -v convert >/dev/null 2>&1; then
  crop_with_imagemagick convert
elif command -v sips >/dev/null 2>&1; then
  # sips fallback: scale to cover, then center-crop to exact dimensions.
  w=$(sips -g pixelWidth "$RAW" | awk '/pixelWidth/{print $2}')
  h=$(sips -g pixelHeight "$RAW" | awk '/pixelHeight/{print $2}')
  if [[ -z "$w" || -z "$h" ]]; then
    echo "error: could not read source image dimensions with sips." >&2
    exit 1
  fi
  # scale factor so both dimensions cover the target, computed in integer math
  if (( w * OG_H >= h * OG_W )); then
    sips --resampleHeight "$OG_H" "$RAW" --out "$OUT" >/dev/null
  else
    sips --resampleWidth "$OG_W" "$RAW" --out "$OUT" >/dev/null
  fi
  sips -c "$OG_H" "$OG_W" "$OUT" --out "$OUT" >/dev/null
else
  echo "error: no image tool found. Install ImageMagick (magick/convert) or use macOS sips to crop the OG image to ${OG_W}x${OG_H}." >&2
  exit 1
fi

if [[ ! -s "$OUT" ]]; then
  echo "error: failed to write OG image to $OUT" >&2
  exit 1
fi
echo "og-image: $OUT (${OG_W}x${OG_H})"
