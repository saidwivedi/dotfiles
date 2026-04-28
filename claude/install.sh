#!/bin/bash
# Install Claude Code configuration from dotfiles

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

cp "$SCRIPT_DIR/CLAUDE.md"          "$CLAUDE_DIR/"
cp "$SCRIPT_DIR/ENV.md"             "$CLAUDE_DIR/"
cp "$SCRIPT_DIR/settings.json"      "$CLAUDE_DIR/"
cp "$SCRIPT_DIR/keybindings.json"   "$CLAUDE_DIR/"
cp "$SCRIPT_DIR/statusline-hud.sh"  "$CLAUDE_DIR/"
chmod +x "$CLAUDE_DIR/statusline-hud.sh"

echo "Claude Code config installed to $CLAUDE_DIR"
echo "Next steps:"
echo "  1. Edit $CLAUDE_DIR/CLAUDE.md   — fill in Identity section"
echo "  2. Edit $CLAUDE_DIR/ENV.md      — fill in cluster paths"
echo "  3. Install claude-hud plugin    — see README.md"
