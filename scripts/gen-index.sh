#!/usr/bin/env bash
# gen-index.sh: walk skills/**/SKILL.md and emit a machine-readable manifest of
# the whole library to stdout (or to scripts/skills-index.json with --write).
#
# The manifest is the bootstrap for the test runner (scripts/test.sh) and the
# seed for a future skill dependency graph. One object per skill:
#   { name, path, category, vendored, source, scripts[] }
#
# Usage:
#   scripts/gen-index.sh            # print JSON to stdout
#   scripts/gen-index.sh --write    # write scripts/skills-index.json

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

command -v jq >/dev/null 2>&1 || { echo "error: jq is required" >&2; exit 1; }

# read a single scalar frontmatter field from a SKILL.md ("" if absent)
fm_field() { # fm_field FILE KEY
  awk -v key="$2" '
    BEGIN{c=0}
    /^---[ \t]*$/{c++; if(c==2) exit; next}
    c==1 && $0 ~ "^"key":" { sub("^"key":[ \t]*",""); print; exit }
  ' "$1"
}

objects=()
while IFS= read -r skill; do
  dir="$(dirname "$skill")"
  # category = first path segment under skills/
  category="${dir#skills/}"; category="${category%%/*}"
  name="$(fm_field "$skill" name)"
  [[ -z "$name" ]] && name="$(basename "$dir")"
  source="$(fm_field "$skill" source)"
  standard="$(fm_field "$skill" standard)"
  vendored=false
  [[ "$standard" == *upstream-vendored* ]] && vendored=true
  # helper scripts living directly beside this SKILL.md (not nested sub-skills)
  # jq 'sort' is codepoint-based and locale-independent, unlike shell sort.
  scripts_json="$(find "$dir" -maxdepth 1 -type f \
      \( -name '*.sh' -o -name '*.py' -o -name '*.ts' -o -name '*.tsx' \) \
      | jq -R . | jq -s 'sort')"
  objects+=("$(jq -n \
    --arg name "$name" --arg path "$skill" --arg category "$category" \
    --argjson vendored "$vendored" \
    --arg source "$source" --argjson scripts "$scripts_json" \
    '{name:$name, path:$path, category:$category, vendored:$vendored,
      source:(if $source=="" then null else $source end), scripts:$scripts}')")
done < <(find skills -name SKILL.md | sort)

# sort_by(.path) makes the array order canonical regardless of the locale that
# `sort` used above, so a fresh generation matches byte-for-byte across machines.
manifest="$(printf '%s\n' "${objects[@]}" | jq -s \
  '{generated_by:"scripts/gen-index.sh", count:length, skills:(sort_by(.path))}')"

if [[ "${1:-}" == "--write" ]]; then
  printf '%s\n' "$manifest" > scripts/skills-index.json
  echo "wrote scripts/skills-index.json ($(jq '.count' <<<"$manifest") skills)" >&2
else
  printf '%s\n' "$manifest"
fi
