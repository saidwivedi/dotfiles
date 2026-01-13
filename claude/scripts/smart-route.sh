#!/bin/bash

# Smart Routing Script - Determines optimal agent for tasks
# Usage: smart-route.sh <task_description> [context_size_estimate]

TASK_DESC="${1:-unknown}"
CONTEXT_SIZE="${2:-0}"

# Token thresholds (configurable)
LIGHT_THRESHOLD=10000    # < 10k tokens = lightweight
MEDIUM_THRESHOLD=50000   # 10k-50k = medium (use optimizer)
HEAVY_THRESHOLD=100000   # > 100k = route to Codex

# Pattern-based complexity detection
COMPLEXITY_SCORE=0

# Architectural patterns (high complexity)
if echo "$TASK_DESC" | grep -qiE '(architectural|entire codebase|comprehensive|migration|security audit|performance profile)'; then
    COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 50000))
fi

# Multi-module patterns (medium complexity)
if echo "$TASK_DESC" | grep -qiE '(multiple modules|across.*components|system-wide|refactor.*all)'; then
    COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + 30000))
fi

# File count patterns
FILE_COUNT=$(echo "$TASK_DESC" | grep -oiE '\b([0-9]+)\s*(files|components|modules)' | head -1 | grep -oE '[0-9]+')
if [ -n "$FILE_COUNT" ]; then
    COMPLEXITY_SCORE=$((COMPLEXITY_SCORE + FILE_COUNT * 1000))
fi

# Add provided context size estimate
TOTAL_ESTIMATE=$((COMPLEXITY_SCORE + CONTEXT_SIZE))

# Routing decision
if [ $TOTAL_ESTIMATE -lt $LIGHT_THRESHOLD ]; then
    echo "ROUTE: claude-code-main"
    echo "REASON: Lightweight task, use main Claude Code instance"
    exit 0
elif [ $TOTAL_ESTIMATE -lt $MEDIUM_THRESHOLD ]; then
    echo "ROUTE: token-optimizer-subagent"
    echo "REASON: Medium complexity, use token-optimizer subagent"
    echo "ESTIMATE: ~$TOTAL_ESTIMATE tokens"
    exit 0
elif [ $TOTAL_ESTIMATE -lt $HEAVY_THRESHOLD ]; then
    echo "ROUTE: token-optimizer-subagent-recommended"
    echo "REASON: High complexity, token-optimizer recommended"
    echo "ESTIMATE: ~$TOTAL_ESTIMATE tokens"
    echo "SUGGESTION: Consider /verify for external Codex review"
    exit 0
else
    echo "ROUTE: codex-external"
    echo "REASON: Very high complexity, route to external Codex"
    echo "ESTIMATE: ~$TOTAL_ESTIMATE tokens"
    echo "ACTION: Use /verify command"
    exit 1  # Exit 1 signals external routing needed
fi
