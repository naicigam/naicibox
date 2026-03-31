#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR: Do not run setup.sh as root or with sudo. It uses sudo internally where needed."
  exit 1
fi

NAICIBOX_HOME="$(cd "$(dirname "$0")" && pwd)"

if [ -z "${PROJECTS_HOME:-}" ]; then
  echo "ERROR: PROJECTS_HOME is not set. Export it before running setup.sh."
  exit 1
fi

echo "==> Naicibox setup"
echo "    NAICIBOX_HOME=$NAICIBOX_HOME"
echo "    PROJECTS_HOME=$PROJECTS_HOME"

# --- 1. Install apt packages ---
echo "==> Installing apt packages..."
sudo apt-get update -qq
sudo apt-get install -y -qq git curl unzip tmux direnv

# --- 2. Install Starship prompt ---
if ! command -v starship &>/dev/null; then
  echo "==> Installing Starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
else
  echo "==> Starship already installed"
fi

# --- 3. Install VS Code ---
if ! command -v code &>/dev/null; then
  echo "==> Installing VS Code..."
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
  sudo apt-get update -qq
  sudo apt-get install -y -qq code
else
  echo "==> VS Code already installed"
fi

# --- 4. Install Claude Code ---
if ! command -v claude &>/dev/null; then
  if ! command -v npm &>/dev/null; then
    echo "ERROR: npm is not installed. Install Node.js/npm first, then re-run setup."
    exit 1
  fi
  echo "==> Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
else
  echo "==> Claude Code already installed"
fi

# --- 5. Deploy .tmux.conf ---
if [ -f "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
  cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak"
  echo "    Backed up ~/.tmux.conf"
fi
cp "$NAICIBOX_HOME/files/.tmux.conf" "$HOME/.tmux.conf"
echo "    Copied .tmux.conf"

# --- 6. Deploy Claude Code settings ---
mkdir -p "$HOME/.claude"
if [ -f "$HOME/.claude/settings.json" ]; then
  cp "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.bak"
  echo "    Backed up ~/.claude/settings.json"
fi
cp "$NAICIBOX_HOME/files/claude-settings.json" "$HOME/.claude/settings.json"
echo "    Copied Claude Code settings"

# --- 7. Inject Naicibox block into ~/.bashrc ---
MARKER_BEGIN="# >>> naicibox >>>"
MARKER_END="# <<< naicibox <<<"

NAICIBOX_BLOCK="$MARKER_BEGIN
eval \"\$(direnv hook bash)\"
eval \"\$(starship init bash)\"
export NAICIBOX_HOME=\"$NAICIBOX_HOME\"
export PROJECTS_HOME=\"$PROJECTS_HOME\"
export PATH=\"\$NAICIBOX_HOME/bin:\$PATH\"
source \"\$NAICIBOX_HOME/files/.bash_aliases\"
$MARKER_END"

if grep -q "$MARKER_BEGIN" "$HOME/.bashrc"; then
  # Replace existing block
  tmpfile=$(mktemp)
  awk -v begin="$MARKER_BEGIN" -v end="$MARKER_END" -v block="$NAICIBOX_BLOCK" '
    $0 == begin { skip=1; print block; next }
    $0 == end { skip=0; next }
    !skip { print }
  ' "$HOME/.bashrc" > "$tmpfile"
  mv "$tmpfile" "$HOME/.bashrc"
  echo "    Updated naicibox block in ~/.bashrc"
else
  # Append new block
  printf '\n%s\n' "$NAICIBOX_BLOCK" >> "$HOME/.bashrc"
  echo "    Added naicibox block to ~/.bashrc"
fi

# --- 8. Create projects directory ---
mkdir -p "$PROJECTS_HOME/.naicibox"
echo "    Created $PROJECTS_HOME"

echo ""
echo "==> Setup complete! Open a new shell or run: source ~/.bashrc"
