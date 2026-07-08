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
curl -fsSL "$RAW/statusline-theme.sh"   -o "$CLAUDE_DIR/statusline-theme.sh"
curl -fsSL "$RAW/statusline-config.sh"  -o "$CLAUDE_DIR/statusline-config.sh"
curl -fsSL "$RAW/lib.sh"                -o "$CLAUDE_DIR/lib.sh"
chmod +x "$CLAUDE_DIR/fetch-usage.sh" "$CLAUDE_DIR/statusline-command.sh" "$CLAUDE_DIR/statusline-theme.sh" "$CLAUDE_DIR/statusline-config.sh"

echo "-> downloading themes"
mkdir -p "$CLAUDE_DIR/themes"
for t in mocha macchiato frappe latte; do
  curl -fsSL "$RAW/themes/$t.sh" -o "$CLAUDE_DIR/themes/$t.sh"
done

echo "-> installing slash commands"
for skill in statusline-theme statusline-config; do
  mkdir -p "$CLAUDE_DIR/skills/$skill"
  curl -fsSL "$RAW/skills/$skill/SKILL.md" -o "$CLAUDE_DIR/skills/$skill/SKILL.md"
done

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
echo "   change theme with: ~/.claude/statusline-theme.sh <mocha|macchiato|frappe|latte>"
echo "   or use the slash commands: /statusline-theme, /statusline-config"
