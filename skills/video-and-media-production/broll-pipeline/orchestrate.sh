#!/usr/bin/env bash
# broll-pipeline orchestrator.
#
# Deterministic stages of the pipeline: render each manifest graphic to a
# transparent ProRes clip, then composite all clips onto the source video at
# their timestamps with ffmpeg. The two creative stages (SCOUT writing the
# manifest, BUILDER writing the Remotion components) are LLM subagent work and
# are NOT run here — this script picks up once a manifest and components exist.
#
# A pipeline-state.json tracks which stages are done so a long run resumes after
# an interruption instead of restarting. Rendering is idempotent: a graphic whose
# clip already exists is skipped.
#
# Usage:
#   orchestrate.sh init      <manifest.json> <source-video>
#   orchestrate.sh status
#   orchestrate.sh render               # render every graphic that lacks a clip
#   orchestrate.sh composite            # overlay all clips onto the source
#   orchestrate.sh run                  # render then composite
#
# No API key, no network. Needs: jq, node/npx (Remotion), ffmpeg.
# Run from the pipeline working directory (where Root.tsx / index.ts live).

set -euo pipefail

STATE="pipeline-state.json"
CLIPS="clips"
OUT="final.mp4"

die() { echo "error: $*" >&2; exit 1; }

need() { command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"; }

read_state() {
  [[ -f "$STATE" ]] || die "no $STATE — run 'orchestrate.sh init <manifest> <video>' first."
  MANIFEST=$(jq -r '.manifest' "$STATE")
  VIDEO=$(jq -r '.video' "$STATE")
  [[ -f "$MANIFEST" ]] || die "manifest not found: $MANIFEST"
  [[ -f "$VIDEO" ]] || die "source video not found: $VIDEO"
}

cmd_init() {
  need jq
  local manifest="${1:-}" video="${2:-}"
  [[ -n "$manifest" && -n "$video" ]] || die "usage: orchestrate.sh init <manifest.json> <source-video>"
  [[ -f "$manifest" ]] || die "manifest not found: $manifest"
  [[ -f "$video" ]] || die "source video not found: $video"
  jq -e '.graphics | type == "array" and length > 0' "$manifest" >/dev/null \
    || die "manifest has no non-empty .graphics array"
  jq -n --arg m "$manifest" --arg v "$video" \
    '{manifest:$m, video:$v, stages:{scout:true, build:"unknown", render:false, composite:false}}' \
    > "$STATE"
  mkdir -p "$CLIPS"
  echo "initialized. manifest=$manifest video=$video"
  echo "next: ensure the BUILDER has generated components, then 'orchestrate.sh run'."
}

cmd_status() {
  need jq
  [[ -f "$STATE" ]] || die "no $STATE — run init first."
  read_state
  local total rendered
  total=$(jq '.graphics | length' "$MANIFEST")
  rendered=0
  while IFS= read -r id; do
    [[ -f "$CLIPS/$id.mov" ]] && rendered=$((rendered + 1))
  done < <(jq -r '.graphics[].id' "$MANIFEST")
  echo "manifest:   $MANIFEST ($total graphics)"
  echo "video:      $VIDEO"
  echo "rendered:   $rendered / $total clips in $CLIPS/"
  echo "composited: $([[ -f "$OUT" ]] && echo "yes ($OUT)" || echo no)"
}

cmd_render() {
  need jq; need npx; need node
  read_state
  local count=0
  while IFS= read -r entry; do
    local id
    id=$(jq -r '.id' <<<"$entry")
    local clip="$CLIPS/$id.mov"
    if [[ -f "$clip" ]]; then
      echo "skip (exists): $clip"
      continue
    fi
    echo "$entry" > ".props.$id.json"
    echo "rendering $id -> $clip"
    npx remotion render index.ts Graphic "$clip" \
      --props=".props.$id.json" \
      --image-format=png --pixel-format=yuva444p10le \
      --codec=prores --prores-profile=4444
    rm -f ".props.$id.json"
    count=$((count + 1))
  done < <(jq -c '.graphics[]' "$MANIFEST")
  jq '.stages.render = true' "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
  echo "rendered $count new clip(s)."
}

cmd_composite() {
  need jq; need ffmpeg
  read_state
  local n
  n=$(jq '.graphics | length' "$MANIFEST")
  [[ "$n" -gt 0 ]] || die "nothing to composite."

  # Confirm every clip exists before building the filter graph.
  while IFS= read -r id; do
    [[ -f "$CLIPS/$id.mov" ]] || die "clip missing for $id — run 'orchestrate.sh render' first."
  done < <(jq -r '.graphics[].id' "$MANIFEST")

  # Build the ffmpeg command: source is input 0, each clip an extra input.
  # Each overlay is time-shifted to its 'in' point and enabled for its window.
  local -a inputs filters maps
  inputs=(-i "$VIDEO")
  local prev="0:v" idx=1
  while IFS= read -r entry; do
    local id tin tout
    id=$(jq -r '.id' <<<"$entry")
    tin=$(jq -r '.in' <<<"$entry")
    tout=$(jq -r '.out' <<<"$entry")
    inputs+=(-i "$CLIPS/$id.mov")
    local cur="v$idx"
    filters+=("[$idx:v]setpts=PTS-STARTPTS+${tin}/TB[o$idx];")
    filters+=("[$prev][o$idx]overlay=enable='between(t,${tin},${tout})':eof_action=pass[$cur];")
    prev="$cur"
    idx=$((idx + 1))
  done < <(jq -c '.graphics[]' "$MANIFEST")

  local filtergraph
  filtergraph=$(printf '%s' "${filters[@]}")
  echo "compositing $n overlay(s) onto $VIDEO -> $OUT"
  ffmpeg -y "${inputs[@]}" \
    -filter_complex "$filtergraph" \
    -map "[$prev]" -map 0:a? -c:a copy -c:v libx264 -crf 18 -pix_fmt yuv420p \
    "$OUT"
  jq '.stages.composite = true' "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
  echo "done: $OUT"
}

cmd_run() { cmd_render; cmd_composite; }

main() {
  local sub="${1:-}"; shift || true
  case "$sub" in
    init)      cmd_init "$@" ;;
    status)    cmd_status ;;
    render)    cmd_render ;;
    composite) cmd_composite ;;
    run)       cmd_run ;;
    *) die "usage: orchestrate.sh {init <manifest> <video>|status|render|composite|run}" ;;
  esac
}

main "$@"
