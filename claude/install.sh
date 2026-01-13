#!/bin/bash
# Install Claude Code configuration from dotfiles

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

# Copy configuration files
cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/"
cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/"

# Copy directories
for dir in hooks commands agents scripts; do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
        cp -r "$SCRIPT_DIR/$dir" "$CLAUDE_DIR/"
    fi
done

# Make hook scripts executable
find "$CLAUDE_DIR/hooks" -type f -name "*.sh" -exec chmod +x {} \;

echo "Claude Code config installed to $CLAUDE_DIR"
