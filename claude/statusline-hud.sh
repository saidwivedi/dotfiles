#!/bin/bash
# claude-hud statusline wrapper:
#   - enables DEBUG=claude-hud and captures stderr to a log file
#   - appends a "check LOG" hint to the status bar when the HUD shows an API error
#
# Requires the claude-hud plugin to be installed via the marketplace.
# Set NODE to your node binary (or rely on $PATH).

LOG=$HOME/.claude/claude-hud.log
NODE="${NODE:-$(command -v node)}"
HUD_DIR=$(ls -td ~/.claude/plugins/cache/claude-hud/claude-hud/*/ 2>/dev/null | head -1)

if [ -z "$HUD_DIR" ] || [ -z "$NODE" ]; then
    printf 'claude-hud not installed'
    exit 0
fi

out=$(DEBUG=claude-hud NODE_USE_ENV_PROXY=1 "$NODE" "${HUD_DIR}dist/index.js" 2>>"$LOG")

# Error line from claude-hud looks like: "Usage ⚠ (network)" / "⚠ (timeout)" / "⚠ (http-401)"
# Limit-reached (not an error) looks like: "⚠ Limit reached (resets ...)"
if printf '%s' "$out" | grep -q '⚠' && ! printf '%s' "$out" | grep -q 'Limit reached'; then
    DIM=$(printf '\033[38;5;238m')
    RESET=$(printf '\033[0m')
    hint=" ${DIM}→ tail ${LOG}${RESET}"
    out="${out}${hint}"
fi

printf '%s' "$out"
