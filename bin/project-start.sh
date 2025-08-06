#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: project-start.sh <project-name>"
  exit 1
fi

PROJECT_NAME="$1"
PROJECT_DIR=$PROJECTS_HOME/$PROJECT_NAME

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Project $PROJECT_NAME not found in $PROJECTS_HOME"
  exit 1
fi

cd "$PROJECT_DIR"

# Launch tmux session if not already active
if ! tmux has-session -t "$PROJECT_NAME" 2>/dev/null; then
  tmux new-session -d -s "$PROJECT_NAME" -c "$PROJECT_DIR"
  tmux rename-window -t "$PROJECT_NAME":0 "console"
  tmux new-window -t "$PROJECT_NAME":1 -n "docker" -c "$PROJECT_DIR"
fi

# Attach to tmux session
tmux attach -t "$PROJECT_NAME"

# Launch VS Code in background
code "$PROJECT_DIR" &
