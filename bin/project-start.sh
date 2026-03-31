#!/bin/bash
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: project-start.sh <project-name>"
  exit 1
fi

if [ -z "${PROJECTS_HOME:-}" ]; then
  echo "ERROR: PROJECTS_HOME is not set. Run setup.sh first."
  exit 1
fi

PROJECT_NAME="$1"
CONFIG_DIR="$PROJECTS_HOME/.naicibox/$PROJECT_NAME"

if [ ! -f "$CONFIG_DIR/path" ]; then
  echo "Project $PROJECT_NAME not found. Run: newproject $PROJECT_NAME"
  exit 1
fi

PROJECT_DIR="$(cat "$CONFIG_DIR/path")"

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Project directory $PROJECT_DIR no longer exists"
  exit 1
fi

cd "$PROJECT_DIR"

# Launch VS Code before tmux attach (attach blocks the script)
code . &

# Launch tmux session if not already active
if ! tmux has-session -t "$PROJECT_NAME" 2>/dev/null; then
  tmux new-session -d -s "$PROJECT_NAME" -c "$PROJECT_DIR" -n "$PROJECT_NAME"
  tmux set-option -t "$PROJECT_NAME" automatic-rename off

  # Set pane title to project name
  tmux select-pane -t "$PROJECT_NAME":1.0 -T "$PROJECT_NAME"

  # Sign in to 1Password if op is available
  if command -v op &>/dev/null; then
    tmux send-keys -t "$PROJECT_NAME":1 'eval $(op signin)' C-m
  fi

  # Source project-specific shell config in both panes
  if [ -f "$CONFIG_DIR/.bashrc" ]; then
    tmux send-keys -t "$PROJECT_NAME":1 "source \"$CONFIG_DIR/.bashrc\"" C-m
  fi

  tmux send-keys -t "$PROJECT_NAME":1 "claude -c --enable-auto-mode" C-m
  tmux split-window -t "$PROJECT_NAME":1 -v -c "$PROJECT_DIR"

  # Set pane title for the bottom pane too
  tmux select-pane -t "$PROJECT_NAME":1.1 -T "$PROJECT_NAME"

  if [ -f "$CONFIG_DIR/.bashrc" ]; then
    tmux send-keys -t "$PROJECT_NAME":1.1 "source \"$CONFIG_DIR/.bashrc\"" C-m
  fi
fi

# Attach to tmux session
tmux attach -t "$PROJECT_NAME"
