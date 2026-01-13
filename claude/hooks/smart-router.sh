#!/bin/bash

# Smart Router Hook - Detects token-heavy patterns and suggests Codex routing
# Event: UserPromptSubmit
# Purpose: Analyze user prompts and suggest external Codex for extremely heavy tasks

# Check if routing is disabled for this session
if [ -f ~/.claude/session-env/routing-disabled ]; then
    # Routing disabled - exit silently
    exit 0
fi

# Read the user prompt from stdin (JSON format from Claude Code)
INPUT=$(cat)
USER_PROMPT=$(echo "$INPUT" | jq -r '.prompt // .content // ""')

# Token-heavy pattern detection
TOKEN_HEAVY_PATTERNS=(
    "comprehensive.*review"
    "analyze.*entire.*codebase"
    "review.*all.*files"
    "search.*everywhere"
    "refactor.*entire"
    "architectural.*analysis"
    "security.*audit"
    "performance.*profile.*all"
    "document.*complete"
    "migrate.*all"
)

# Check if prompt matches token-heavy patterns
MATCHED=false
for pattern in "${TOKEN_HEAVY_PATTERNS[@]}"; do
    if echo "$USER_PROMPT" | grep -qiE "$pattern"; then
        MATCHED=true
        break
    fi
done

# Count-based detection: if user mentions many files
FILE_COUNT=$(echo "$USER_PROMPT" | grep -oiE '\b[0-9]+\s*(files|components|modules)' | head -1)
if [[ "$FILE_COUNT" =~ ([0-9]+) ]] && [ "${BASH_REMATCH[1]}" -gt 20 ]; then
    MATCHED=true
fi

# If matched, suggest Codex routing
if [ "$MATCHED" = true ]; then
    cat <<EOF

───────────────────────────────────────────────────────
⚡ TOKEN OPTIMIZATION SUGGESTION

This request appears to be token-intensive. Consider:

1. Use token-optimizer subagent (automatic - will happen)
   → Optimized for multi-file analysis within Claude Code

2. For comprehensive analysis, use: /verify
   → Routes to external Codex with larger context window
   → Better for architectural reviews and massive refactors

Proceeding with token-optimizer subagent...
───────────────────────────────────────────────────────

EOF
fi

# Always allow the prompt to proceed (don't block)
exit 0
