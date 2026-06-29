#!/usr/bin/env bash
# heavy-file-ingestion: convert heavy files (PDF, slides, spreadsheets, CSV
# dumps, long docs) into lightweight Markdown/CSV artifacts plus an index,
# BEFORE any analysis. Analysis then reads the artifacts, never the original.
#
# Usage:
#   ingest.sh report.pdf deck.pptx data.csv
#   ingest.sh bigdoc.docx --max-lines 800
#   ingest.sh data.csv --out /path/to/_ingested
#
# Output: an "_ingested/" folder next to each source (overridable with --out),
# containing the converted artifact(s), chunk files for large sources, and a
# shared INDEX.md listing every artifact with a one-line summary.
#
# No API key required. Office/PDF conversion uses markitdown if present; CSV and
# plain-text conversion need no external tools.

set -euo pipefail

MAX_LINES=1200
OUT_OVERRIDE=""
FILES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --max-lines) MAX_LINES="${2:-1200}"; shift 2;;
    --out)       OUT_OVERRIDE="${2:-}";  shift 2;;
    -*) echo "unknown argument: $1" >&2; exit 1;;
    *)  FILES+=("$1"); shift;;
  esac
done

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "usage: ingest.sh FILE [FILE ...] [--max-lines N] [--out DIR]" >&2
  exit 1
fi

# write a one-line-summary index row for an artifact
summarize() {  # $1 = artifact path
  local s
  s=$(grep -m1 -E '^#{1,6} ' "$1" 2>/dev/null | sed 's/^#\{1,6\} *//')
  [[ -z "$s" ]] && s=$(grep -m1 -E '\S' "$1" 2>/dev/null || true)
  s=${s//|/ }            # keep markdown table cells intact
  printf '%.120s' "$s"
}

chunk_if_large() {  # $1 = markdown artifact, $2 = output dir, $3 = stem ; echoes chunk count
  local art="$1" dir="$2" stem="$3" lines
  lines=$(wc -l < "$art" | tr -d ' ')
  if (( lines > MAX_LINES )); then
    awk -v max="$MAX_LINES" -v base="$dir/$stem" '
      BEGIN { p=1; n=0; f=sprintf("%s.chunk%02d.md", base, p) }
      { print > f; n++; if (n>=max) { close(f); p++; n=0; f=sprintf("%s.chunk%02d.md", base, p) } }
      END { if (n==0) p-- ; print p }
    ' "$art"
  else
    echo 0
  fi
}

INDEX=""   # set per source dir

index_init() {  # $1 = dir
  INDEX="$1/INDEX.md"
  if [[ ! -f "$INDEX" ]]; then
    {
      echo "# Ingested artifacts index"
      echo
      echo "Analysis reads these artifacts, never the original heavy files."
      echo
      echo "| Source | Type | Artifact | Lines/Rows | Chunks | Summary |"
      echo "|---|---|---|---|---|---|"
    } > "$INDEX"
  fi
}

for src in "${FILES[@]}"; do
  if [[ ! -f "$src" ]]; then echo "skip (not a file): $src" >&2; continue; fi
  srcdir=$(cd "$(dirname "$src")" && pwd)
  base=$(basename "$src")
  stem="${base%.*}"
  ext="${base##*.}"; ext="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"
  outdir="${OUT_OVERRIDE:-$srcdir/_ingested}"
  mkdir -p "$outdir"
  index_init "$outdir"

  artifact=""; type=""; measure=""; chunks=0

  case "$ext" in
    pdf|docx|doc|pptx|ppt|xlsx|xls|html|htm|epub)
      type="$ext"
      if ! command -v markitdown >/dev/null 2>&1; then
        echo "skip ($base): markitdown not installed. Install with: pip install 'markitdown[all]'" >&2
        echo "| $base | $type | (not converted) | - | - | needs: pip install markitdown |" >> "$INDEX"
        continue
      fi
      artifact="$outdir/$stem.md"
      markitdown "$src" > "$artifact"
      measure="$(wc -l < "$artifact" | tr -d ' ') lines"
      chunks=$(chunk_if_large "$artifact" "$outdir" "$stem")
      ;;
    csv)
      type="csv"
      artifact="$outdir/$base"
      cp "$src" "$artifact"
      rows=$(( $(wc -l < "$src" | tr -d ' ') ))
      cols=$(awk -F, 'NR==1{print NF; exit}' "$src")
      {
        echo "# CSV summary: $base"
        echo
        echo "- rows (incl. header): $rows"
        echo "- columns: $cols"
        echo
        echo "## Header"
        echo
        echo '```'
        head -1 "$src"
        echo '```'
        echo
        echo "## First rows"
        echo
        echo '```'
        head -6 "$src"
        echo '```'
        echo
        echo "_Column count is a naive comma split; quoted commas may inflate it._"
      } > "$outdir/$stem.summary.md"
      measure="$rows rows"
      artifact="$outdir/$stem.summary.md"   # index points at the readable summary
      ;;
    txt|text|md|markdown|log)
      type="text"
      artifact="$outdir/$stem.md"
      cp "$src" "$artifact"
      measure="$(wc -l < "$artifact" | tr -d ' ') lines"
      chunks=$(chunk_if_large "$artifact" "$outdir" "$stem")
      ;;
    *)
      echo "skip ($base): unsupported type .$ext" >&2
      echo "| $base | $ext | (unsupported) | - | - | no recipe for .$ext |" >> "$INDEX"
      continue
      ;;
  esac

  summary=$(summarize "$artifact")
  printf '| %s | %s | %s | %s | %s | %s |\n' \
    "$base" "$type" "$(basename "$artifact")" "$measure" "$chunks" "${summary:-(none)}" >> "$INDEX"
  if (( chunks > 0 )); then
    echo "ingested: $base -> $(basename "$artifact") (${chunks} chunks)"
  else
    echo "ingested: $base -> $(basename "$artifact")"
  fi
done

echo "index: ${INDEX:-<none written>}"
