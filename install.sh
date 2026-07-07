#!/bin/sh
# claude-statusline installer.
# Usage: curl -fsSL https://raw.githubusercontent.com/JoseVelazcoH/claude-statusline/main/install.sh | sh
set -e

RAW="https://raw.githubusercontent.com/JoseVelazcoH/claude-statusline/main"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"

command -v curl >/dev/null 2>&1 || { echo "error: curl is required" >&2; exit 1; }
command -v jq   >/dev/null 2>&1 || { echo "error: jq is required"   >&2; exit 1; }

mkdir -p "$CLAUDE_DIR"

echo "-> downloading scripts"
curl -fsSL "$RAW/fetch-usage.sh"        -o "$CLAUDE_DIR/fetch-usage.sh"
curl -fsSL "$RAW/statusline-command.sh" -o "$CLAUDE_DIR/statusline-command.sh"
chmod +x "$CLAUDE_DIR/fetch-usage.sh" "$CLAUDE_DIR/statusline-command.sh"

echo "-> configuring settings.json"
new_settings=$(curl -fsSL "$RAW/settings.json")

if [ -f "$SETTINGS" ]; then
  # merge our statusLine + hooks into the existing settings, keeping everything else
  merged=$(jq -s '.[0] * .[1]' "$SETTINGS" - <<EOF
$new_settings
EOF
)
  printf '%s\n' "$merged" > "$SETTINGS"
else
  printf '%s\n' "$new_settings" > "$SETTINGS"
fi

echo "-> done. restart Claude Code to see the statusline."
