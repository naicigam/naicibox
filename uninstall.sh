#!/bin/bash
set -euo pipefail

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
Usage: uninstall.sh

Reverse what setup.sh changed on this host:

  - Strip the naicibox block from ~/.bashrc (between the markers
    "# >>> naicibox >>>" and "# <<< naicibox <<<").
  - Restore the most recent ~/.tmux.conf.bak* and
    ~/.claude/settings.json.bak* if any exist (older backups are left
    in place untouched). Warns if no backup is present.
  - Leave installed packages (tmux, direnv, starship, code, claude),
    PROJECTS_HOME, and per-project trees alone; they are reported as
    "left behind" so you can act on them yourself.

Exit codes:
  0  success (including no-op when nothing was installed)
  1  unexpected error
USAGE
    exit 0
    ;;
esac

MARKER_BEGIN="# >>> naicibox >>>"
MARKER_END="# <<< naicibox <<<"

echo "==> Naicibox uninstall"

# --- 1. Strip naicibox block from ~/.bashrc ---
if [ -f "$HOME/.bashrc" ] && grep -q "$MARKER_BEGIN" "$HOME/.bashrc"; then
  tmpfile=$(mktemp)
  awk -v begin="$MARKER_BEGIN" -v end="$MARKER_END" '
    $0 == begin { skip=1; next }
    $0 == end   { skip=0; next }
    !skip       { print }
  ' "$HOME/.bashrc" > "$tmpfile"
  mv "$tmpfile" "$HOME/.bashrc"
  echo "    Removed naicibox block from ~/.bashrc"
else
  echo "    No naicibox block found in ~/.bashrc"
fi

# --- 2. Restore deployed dotfiles from most-recent .bak ---
restore_latest_bak() {
  local target="$1"
  # Match both legacy untimestamped backups and the YYYYMMDD-HHMMSS form
  # used by setup.sh after NT-0021. Sort by filename in reverse so the
  # highest timestamp wins; the legacy ".bak" sorts last and is used only
  # as a fallback.
  local newest
  newest=$(ls -1 "$target".bak.* "$target.bak" 2>/dev/null | sort -r | head -n1 || true)
  if [ -n "$newest" ] && [ -f "$newest" ]; then
    cp "$newest" "$target"
    echo "    Restored $target from $newest"
  else
    echo "    WARNING: no backup found for $target — leaving naicibox copy in place"
  fi
}

if [ -f "$HOME/.tmux.conf" ]; then
  restore_latest_bak "$HOME/.tmux.conf"
fi

if [ -f "$HOME/.claude/settings.json" ]; then
  restore_latest_bak "$HOME/.claude/settings.json"
fi

# --- 3. Report what is left behind ---
echo ""
echo "==> Uninstall complete. Left in place (remove manually if desired):"
for cmd in tmux direnv starship code claude; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "    - $cmd ($(command -v "$cmd"))"
  fi
done
if [ -n "${PROJECTS_HOME:-}" ] && [ -d "$PROJECTS_HOME" ]; then
  echo "    - PROJECTS_HOME=$PROJECTS_HOME (project trees and .naicibox config)"
fi
echo ""
echo "Open a new shell or run: source ~/.bashrc"
