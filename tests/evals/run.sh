#!/usr/bin/env bash
# tests/evals/run.sh — Tier 2 of the quality-test system.
#
# Behavioral evals for the highest-value skills and all runbooks. Each case pairs
# a fixture input with a rubric derived from the target's own Verification
# standard. A run has an agent execute the target against the fixture, then an
# LLM judge scores the output against each rubric criterion.
#
# This is deliberately NOT on the CI pull-request gate: it costs tokens and is
# non-deterministic. By default it runs in --validate mode, which is free and
# offline: it checks that every case is well-formed and points at a real target.
# The scored judge run is gated behind an explicit flag plus a key.
#
# Usage:
#   tests/evals/run.sh                 # validate all cases (offline, free)
#   tests/evals/run.sh --validate      # same, explicit
#   AGENT_SKILLS_EVAL=1 ANTHROPIC_API_KEY=... tests/evals/run.sh --run
#                                      # execute + judge (spends tokens)
#
# Case schema (tests/evals/cases/*.json):
#   { "target": "<repo-relative SKILL.md or RUNBOOK.md>",
#     "kind": "skill" | "runbook",
#     "fixture": "<repo-relative fixture file>",
#     "rubric": [ { "id": "...", "criterion": "..." }, ... ],
#     "notes": "..." }

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
CASES_DIR="tests/evals/cases"

command -v jq >/dev/null 2>&1 || { echo "error: jq required" >&2; exit 1; }

MODE="--validate"
[[ "${1:-}" == "--run" ]] && MODE="--run"

# ---- offline validation: every case is well-formed and resolvable ----
validate() {
  local fails=0 n=0
  for c in "$CASES_DIR"/*.json; do
    [[ -e "$c" ]] || { echo "no cases found in $CASES_DIR" >&2; return 1; }
    n=$((n+1))
    jq -e . "$c" >/dev/null 2>&1 || { echo "  FAIL invalid JSON: $c"; fails=$((fails+1)); continue; }
    local target kind fixture ncrit
    target=$(jq -r '.target // ""' "$c")
    kind=$(jq -r '.kind // ""' "$c")
    fixture=$(jq -r '.fixture // ""' "$c")
    ncrit=$(jq '.rubric | length' "$c")
    [[ -f "$target" ]]  || { echo "  FAIL target missing: $target ($c)"; fails=$((fails+1)); }
    [[ "$kind" == "skill" || "$kind" == "runbook" ]] || { echo "  FAIL bad kind '$kind': $c"; fails=$((fails+1)); }
    [[ -f "$fixture" ]] || { echo "  FAIL fixture missing: $fixture ($c)"; fails=$((fails+1)); }
    [[ "$ncrit" -ge 1 ]] || { echo "  FAIL no rubric criteria: $c"; fails=$((fails+1)); }
    # every rubric entry needs a non-empty id and criterion (guards against a
    # malformed rubric that has the right length but empty content).
    jq -e '.rubric | all((.id // "") != "" and (.criterion // "") != "")' "$c" >/dev/null 2>&1 \
      || { echo "  FAIL rubric has an empty id or criterion: $c"; fails=$((fails+1)); }
    printf '  %-28s -> %-8s %2s criteria  (%s)\n' "$(basename "$c" .json)" "$kind" "$ncrit" "$target"
  done
  echo
  echo "validated $n case(s), $fails problem(s)"
  return $((fails > 0))
}

# ---- gated judge run: execute the target on the fixture, then score ----
run_judged() {
  if [[ "${AGENT_SKILLS_EVAL:-}" != "1" || -z "${ANTHROPIC_API_KEY:-}" ]]; then
    echo "refusing to run: set AGENT_SKILLS_EVAL=1 and ANTHROPIC_API_KEY to spend tokens." >&2
    echo "(this path is intentionally kept off the free CI gate.)" >&2
    exit 2
  fi
  validate || { echo "cases invalid; fix before running." >&2; exit 1; }
  echo
  echo "== judged run =="
  # Execution + judging is the model-backed step. It is scaffolded here so the
  # case format and validation are usable today; wire the actual agent call and
  # judge prompt in when a model budget is approved for evals. Each case yields a
  # per-criterion pass/fail plus a short rationale, aggregated into a scored
  # report under tests/evals/reports/<date>/.
  echo "TODO: agent execution + LLM-judge scoring (budget-approved step)."
  echo "Cases are validated and ready; no scoring performed."
}

case "$MODE" in
  --validate) validate ;;
  --run)      run_judged ;;
esac
