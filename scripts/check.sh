#!/usr/bin/env bash
# agent-skills repository checks.
#
# Static, dependency-light gates that run locally and in CI. No network, no keys.
#
# Checks:
#   1. shell syntax    — bash -n on every *.sh
#   2. python syntax   — py_compile on every *.py
#   3. json parse      — jq empty on every *.json
#   4. six-element     — non-vendored SKILL.md carry all six authoring elements
#   5. provenance      — every vendored skill declares source:
#   6. runbook refs    — every category/skill named in a RUNBOOK resolves on disk
#   7. writing rules   — non-vendored SKILL.md / RUNBOOK.md avoid inline bold and AI-isms
#   8. manifest fresh  — scripts/skills-index.json matches a fresh generation
#   9. section content — native Output contract / Verification sections are non-empty
#  10. runbook shape   — every runbook composes at least two distinct skills
#
# Vendored skills (standard: upstream-vendored) are exempt from the authoring
# and writing-rule gates; they are still syntax-checked and provenance-checked.

set -uo pipefail
cd "$(dirname "$0")/.."

fails=0
note() { printf '  %s\n' "$1"; }
section() { printf '\n[%s] %s\n' "$1" "$2"; }

is_vendored() { grep -q '^standard: upstream-vendored' "$1" 2>/dev/null; }

# Skill dirs that are vendored, so file-level checks can skip everything under them.
vendored_dirs=()
while IFS= read -r f; do
  is_vendored "$f" && vendored_dirs+=("$(dirname "$f")")
done < <(find skills -name SKILL.md)

under_vendored() {
  local path="$1" d
  for d in "${vendored_dirs[@]}"; do
    [[ "$path" == "$d"/* ]] && return 0
  done
  return 1
}

# --- 1. shell syntax ---
section 1 "shell syntax (bash -n)"
n=0
while IFS= read -r f; do
  bash -n "$f" 2>/dev/null || { note "SYNTAX: $f"; fails=$((fails+1)); }
  n=$((n+1))
done < <(find skills scripts tests -name '*.sh')
note "checked $n shell scripts"

# --- 2. python syntax ---
section 2 "python syntax (py_compile)"
n=0
while IFS= read -r f; do
  python3 -m py_compile "$f" 2>/dev/null || { note "PYERR: $f"; fails=$((fails+1)); }
  n=$((n+1))
done < <(find skills -name '*.py')
note "checked $n python files"

# --- 3. json parse ---
section 3 "json parse (jq)"
n=0
while IFS= read -r f; do
  jq empty "$f" 2>/dev/null || { note "JSONERR: $f"; fails=$((fails+1)); }
  n=$((n+1))
done < <(find skills -name '*.json' -not -name 'agent-native-skill.json')
note "checked $n json files"

# --- 4. six-element standard (non-vendored SKILL.md) ---
section 4 "six-element authoring standard (native skills)"
n=0
while IFS= read -r f; do
  is_vendored "$f" && continue
  n=$((n+1))
  fm=$(awk 'BEGIN{c=0} /^---[ \t]*$/{c++; next} c==1{print}' "$f")
  for key in name: description: tags: audience:; do
    grep -q "^$key" <<<"$fm" || { note "MISSING frontmatter $key: $f"; fails=$((fails+1)); }
  done
  grep -qE '^## Output contract' "$f"      || { note "MISSING Output contract: $f"; fails=$((fails+1)); }
  grep -qE '^## Verification' "$f"          || { note "MISSING Verification: $f"; fails=$((fails+1)); }
  grep -qE '\bNever\b' "$f"                 || { note "MISSING Never-guardrail: $f"; fails=$((fails+1)); }
done < <(find skills -name SKILL.md)
note "checked $n native SKILL.md"

# --- 5. provenance integrity (vendored skills declare source:) ---
section 5 "provenance (vendored skills declare source:)"
n=0
for d in "${vendored_dirs[@]}"; do
  n=$((n+1))
  grep -q '^source:' "$d/SKILL.md" || { note "MISSING source: $d/SKILL.md"; fails=$((fails+1)); }
done
note "checked $n vendored skills"

# --- 6. runbook references resolve ---
section 6 "runbook references resolve to real skills"
n=0
while IFS= read -r rb; do
  while IFS= read -r ref; do
    [ -f "skills/$ref/SKILL.md" ] || { note "BROKEN ref '$ref' in $rb"; fails=$((fails+1)); }
    n=$((n+1))
  done < <(grep -hoE '`[a-z-]+/[a-z-]+`' "$rb" | tr -d '`' | sort -u)
done < <(find runbooks -name RUNBOOK.md)
note "checked $n runbook references"

# --- 7. writing rules (non-vendored SKILL.md + RUNBOOK.md) ---
# my-voice is exempt: its job is to enumerate the AI-isms to avoid.
section 7 "writing rules (no inline bold, no AI-isms)"
n=0
while IFS= read -r f; do
  under_vendored "$f" && continue
  [[ "$f" == *"/my-voice/SKILL.md" ]] && continue
  n=$((n+1))
  if grep -nE '\*\*|[^a-z-]leverage|[^a-z-]utilize|seamless|cutting-edge' "$f" >/dev/null 2>&1; then
    note "WRITING: $f"
    grep -nE '\*\*|[^a-z-]leverage|[^a-z-]utilize|seamless|cutting-edge' "$f" | head -3 | sed 's/^/    /'
    fails=$((fails+1))
  fi
done < <(find skills runbooks -name 'SKILL.md' -o -name 'RUNBOOK.md')
note "checked $n procedure files"

# --- 8. manifest freshness (scripts/skills-index.json is current) ---
section 8 "skills-index.json is up to date"
if [ -f scripts/skills-index.json ]; then
  # compare content, not byte formatting, so jq version differences across
  # machines (macOS vs CI) never produce a false "stale".
  if [ "$(bash scripts/gen-index.sh | jq -S .)" = "$(jq -S . scripts/skills-index.json)" ]; then
    note "manifest matches a fresh generation"
  else
    note "STALE: scripts/skills-index.json — run scripts/gen-index.sh --write"
    fails=$((fails+1))
  fi
else
  note "MISSING: scripts/skills-index.json — run scripts/gen-index.sh --write"
  fails=$((fails+1))
fi

# --- 9. section content (native Output contract / Verification are non-empty) ---
# extract the body under a "## <heading>" up to the next "## " and report whether
# it holds any non-blank line (i.e. the section is more than just its header).
section_has_body() { # section_has_body FILE HEADING
  awk -v h="$2" '
    $0 ~ "^## " h { grab=1; next }
    grab && /^## / { exit }
    grab && NF { found=1 }
    END { exit(found?0:1) }
  ' "$1"
}
section 9 "native section content (non-empty contract + verification)"
n=0
while IFS= read -r f; do
  is_vendored "$f" && continue
  n=$((n+1))
  section_has_body "$f" "Output contract" || { note "EMPTY Output contract: $f"; fails=$((fails+1)); }
  section_has_body "$f" "Verification"     || { note "EMPTY Verification: $f"; fails=$((fails+1)); }
done < <(find skills -name SKILL.md)
note "checked $n native SKILL.md"

# --- 10. runbook composition (each runbook chains >= 2 distinct skills) ---
section 10 "runbook composition (>= 2 distinct skills)"
n=0
while IFS= read -r rb; do
  n=$((n+1))
  refs=$(grep -hoE '`[a-z-]+/[a-z-]+`' "$rb" | tr -d '`' | sort -u | grep -c . )
  [ "$refs" -ge 2 ] || { note "THIN runbook ($refs skill refs): $rb"; fails=$((fails+1)); }
done < <(find runbooks -name RUNBOOK.md)
note "checked $n runbooks"

# --- result ---
printf '\n'
if [ "$fails" -eq 0 ]; then
  echo "PASS — all checks green"
  exit 0
else
  echo "FAIL — $fails problem(s) above"
  exit 1
fi
