#!/usr/bin/env bash
# install.sh: make the library's skills discoverable by Claude Code.
#
# The library stores skills in a taxonomy — skills/<category>/<skill>/SKILL.md —
# but Claude Code only scans a flat directory: ~/.claude/skills/<skill>/SKILL.md
# (global) or <project>/.claude/skills/<skill>/SKILL.md (project). This script
# flattens the taxonomy into that location so every top-level skill shows up in
# a fresh session. Nested sub-skills (e.g. frontend-taste/<sub>/SKILL.md) ride
# along inside their parent skill folder and are not installed as their own
# top-level skill, which matches how they are meant to load.
#
# Default: symlink every top-level skill into ~/.claude/skills so the repo stays
# the single source of truth and edits are live. Use --copy for standalone copies.
#
# Usage:
#   scripts/install.sh                 # symlink all skills into ~/.claude/skills
#   scripts/install.sh --copy          # copy instead of symlink
#   scripts/install.sh --project [DIR] # install into DIR/.claude/skills (DIR defaults to cwd)
#   scripts/install.sh --force         # replace existing real directories, not just symlinks
#   scripts/install.sh --dry-run       # print what would happen, change nothing
#   scripts/install.sh --uninstall     # remove skills previously linked/copied from this repo
#   scripts/install.sh --list          # list the installable top-level skills and exit

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

MODE=symlink        # symlink | copy
SCOPE=global        # global | project
PROJECT_DIR=""
FORCE=0
DRY_RUN=0
ACTION=install      # install | uninstall | list

while [ $# -gt 0 ]; do
  case "$1" in
    --copy)      MODE=copy ;;
    --symlink)   MODE=symlink ;;
    --project)   SCOPE=project
                 if [ $# -ge 2 ] && [ "${2#-}" = "$2" ]; then PROJECT_DIR="$2"; shift; fi ;;
    --force)     FORCE=1 ;;
    --dry-run)   DRY_RUN=1 ;;
    --uninstall) ACTION=uninstall ;;
    --list)      ACTION=list ;;
    -h|--help)   sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

# Resolve the destination skills directory.
if [ "$SCOPE" = project ]; then
  base="${PROJECT_DIR:-$PWD}"
  DEST="$base/.claude/skills"
else
  DEST="${HOME}/.claude/skills"
fi

# Collect the installable top-level skills: immediate <category>/<skill> dirs
# under skills/ that contain a SKILL.md at their root.
skills=()
while IFS= read -r skillmd; do
  skills+=("$(dirname "$skillmd")")
done < <(find "$REPO_ROOT/skills" -mindepth 3 -maxdepth 3 -name SKILL.md | sort)

if [ "$ACTION" = list ]; then
  echo "Installable top-level skills (${#skills[@]}):"
  for d in "${skills[@]}"; do echo "  $(basename "$d")"; done
  exit 0
fi

say() { printf '%s\n' "$1"; }
run() { if [ "$DRY_RUN" -eq 1 ]; then echo "  [dry-run] $*"; else eval "$@"; fi; }

# points_into_repo TARGET — true if TARGET is a symlink resolving under REPO_ROOT.
points_into_repo() {
  local t="$1" real
  [ -L "$t" ] || return 1
  real="$(cd "$(dirname "$t")" && cd "$(dirname "$(readlink "$t")")" 2>/dev/null && pwd)" || return 1
  case "$real" in "$REPO_ROOT"/*|"$REPO_ROOT") return 0 ;; *) return 1 ;; esac
}

if [ "$ACTION" = uninstall ]; then
  removed=0
  for src in "${skills[@]}"; do
    name="$(basename "$src")"
    target="$DEST/$name"
    if points_into_repo "$target"; then
      run rm -f "'$target'"; removed=$((removed+1))
    elif [ -e "$target" ] && [ "$FORCE" -eq 1 ]; then
      run rm -rf "'$target'"; removed=$((removed+1))
    fi
  done
  say "Uninstalled $removed skill(s) from $DEST"
  exit 0
fi

# install
say "Installing ${#skills[@]} skills into $DEST  (mode: $MODE)"
[ "$DRY_RUN" -eq 1 ] || mkdir -p "$DEST"

installed=0 relinked=0 skipped=0
for src in "${skills[@]}"; do
  name="$(basename "$src")"
  target="$DEST/$name"

  if [ -L "$target" ]; then
    # existing symlink — safe to replace (re-point at current repo path)
    run rm -f "'$target'"; relinked=$((relinked+1))
  elif [ -e "$target" ]; then
    # existing real file/dir (e.g. an old hand-copied skill)
    if [ "$FORCE" -eq 1 ]; then
      run rm -rf "'$target'"
    else
      say "  skip  $name — a real directory already exists (use --force to replace)"
      skipped=$((skipped+1)); continue
    fi
  fi

  if [ "$MODE" = symlink ]; then
    run ln -s "'$src'" "'$target'"
  else
    run cp -R "'$src'" "'$target'"
  fi
  installed=$((installed+1))
done

say ""
say "Done. installed/updated: $installed   (of which relinked: $relinked)   skipped: $skipped"
say "Open a fresh Claude Code session; the skills are invocable as /<skill-name>."
