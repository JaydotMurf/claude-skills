#!/usr/bin/env bash
# media-transcription: turn a local audio/video file into a standard transcript
# package using the AssemblyAI API.
#
# Usage:
#   transcribe.sh path/to/media.mp3
#   transcribe.sh path/to/talk.mp4 --no-chapters
#   transcribe.sh path/to/call.wav --no-diarization
#
# Output: a "<media-without-ext>.transcript/" folder next to the source, holding
#   transcript.json   full raw API response (source of truth for other skills)
#   transcript.md     readable, speaker-labeled, timestamped
#   words.json        word-level timestamps
#   chapters.md       semantic chapters
#
# The API key is read from the env file, never passed on the command line.
# Resolution order: MEDIA_TRANSCRIPTION_API_KEY, then ASSEMBLYAI_API_KEY.

set -euo pipefail

ENV_FILE="${AGENT_SKILLS_ENV:-$HOME/.config/agent-skills/.env}"
BASE="https://api.assemblyai.com"

for bin in curl jq; do
  command -v "$bin" >/dev/null 2>&1 || { echo "error: missing dependency: $bin" >&2; exit 1; }
done

# --- load secrets ---
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi
API_KEY="${MEDIA_TRANSCRIPTION_API_KEY:-${ASSEMBLYAI_API_KEY:-}}"
if [[ -z "$API_KEY" ]]; then
  echo "error: no API key found. Add ASSEMBLYAI_API_KEY (or MEDIA_TRANSCRIPTION_API_KEY) to $ENV_FILE" >&2
  exit 1
fi

# --- parse args ---
MEDIA="${1:-}"; shift || true
DIARIZE=true; CHAPTERS=true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-diarization) DIARIZE=false; shift;;
    --no-chapters)    CHAPTERS=false; shift;;
    *) echo "unknown argument: $1" >&2; exit 1;;
  esac
done
if [[ -z "$MEDIA" || ! -f "$MEDIA" ]]; then
  echo "usage: transcribe.sh path/to/media [--no-diarization] [--no-chapters]" >&2
  exit 1
fi

OUTDIR="${MEDIA%.*}.transcript"
mkdir -p "$OUTDIR"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# --- if the source is video, extract audio first ---
ext="${MEDIA##*.}"; ext="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"
UPLOAD_FILE="$MEDIA"
case "$ext" in
  mp4|mov|mkv|webm|avi|m4v)
    command -v ffmpeg >/dev/null 2>&1 || {
      echo "error: ffmpeg is required to transcribe video. Install it (macOS: brew install ffmpeg), or pass an audio file." >&2
      exit 1; }
    echo "extracting audio from video..."
    ffmpeg -y -loglevel error -i "$MEDIA" -vn -ac 1 -ar 16000 -c:a aac "$tmpdir/audio.m4a"
    UPLOAD_FILE="$tmpdir/audio.m4a"
    ;;
esac

# --- upload ---
echo "uploading..."
upload_url=$(curl -sS -X POST "$BASE/v2/upload" \
  -H "Authorization: $API_KEY" \
  --data-binary @"$UPLOAD_FILE" | jq -r '.upload_url // empty')
if [[ -z "$upload_url" ]]; then
  echo "error: upload failed (no upload_url returned)" >&2
  exit 1
fi

# --- create the transcript job ---
req=$(jq -n --arg url "$upload_url" --argjson diar "$DIARIZE" --argjson chap "$CHAPTERS" \
  '{audio_url:$url, speech_models:["universal-3-pro","universal-2"],
    speaker_labels:$diar, auto_chapters:$chap, punctuate:true, format_text:true}')
id=$(curl -sS -X POST "$BASE/v2/transcript" \
  -H "Authorization: $API_KEY" -H "Content-Type: application/json" \
  -d "$req" | jq -r '.id // empty')
if [[ -z "$id" ]]; then
  echo "error: could not create transcript job" >&2
  exit 1
fi

# --- poll until done ---
echo "transcribing (job $id)..."
deadline=$((SECONDS + 1800))
resp=""
while :; do
  resp=$(curl -sS "$BASE/v2/transcript/$id" -H "Authorization: $API_KEY")
  status=$(jq -r '.status // "unknown"' <<<"$resp")
  case "$status" in
    completed) break;;
    error) echo "error: $(jq -r '.error // "transcription failed"' <<<"$resp")" >&2; exit 1;;
    queued|processing) ;;
    *) echo "error: unexpected status: $status" >&2; exit 1;;
  esac
  if (( SECONDS > deadline )); then echo "error: timed out after 30m" >&2; exit 1; fi
  sleep 3
done

# --- write artifacts (raw first, so it survives any derivation issue) ---
printf '%s' "$resp" | jq '.' > "$OUTDIR/transcript.json"
jq '.words // []' <<<"$resp" > "$OUTDIR/words.json"

# transcript.md: speaker-labeled, timestamped utterances; plain text fallback
{
  echo "# Transcript: $(basename "$MEDIA")"
  echo
  echo "Generated $(date +%Y-%m-%d) via AssemblyAI."
  echo
  jq -r '
    def pad2: tostring | if length < 2 then "0" + . else . end;
    def ts(ms): (ms/1000|floor) as $s
      | "\(($s/3600|floor)):\((($s%3600)/60|floor)|pad2):\(($s%60)|pad2)";
    if (.utterances | type) == "array" and (.utterances | length) > 0
    then .utterances[] | "[\(ts(.start))] Speaker \(.speaker): \(.text)\n"
    else (.text // "(no transcript text returned)")
    end' <<<"$resp"
} > "$OUTDIR/transcript.md"

# chapters.md
{
  echo "# Chapters: $(basename "$MEDIA")"
  echo
  jq -r '
    def pad2: tostring | if length < 2 then "0" + . else . end;
    def ts(ms): (ms/1000|floor) as $s
      | "\(($s/3600|floor)):\((($s%3600)/60|floor)|pad2):\(($s%60)|pad2)";
    if (.chapters | type) == "array" and (.chapters | length) > 0
    then .chapters[] | "## [\(ts(.start))] \(.headline)\n\n\(.gist)\n\n\(.summary)\n"
    else "(no chapters; run without --no-chapters, or the audio was too short)"
    end' <<<"$resp"
} > "$OUTDIR/chapters.md"

echo "done. package: $OUTDIR"
ls -1 "$OUTDIR"
