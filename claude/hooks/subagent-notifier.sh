#!/bin/bash

# Subagent Notification Hook - Alerts when Claude delegates to subagents
# Event: PreToolUse (Task tool)
# Purpose: Provide visibility into subagent routing decisions

# Check if routing is disabled for this session
if [ -f ~/.claude/session-env/routing-disabled ]; then
    # Routing disabled - exit silently
    exit 0
fi

# Read the tool use input from stdin (JSON format)
INPUT=$(cat)

# Extract subagent type if this is a Task tool call
SUBAGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // empty' 2>/dev/null)

# Only notify for specific subagents we care about
if [ "$SUBAGENT_TYPE" = "token-optimizer" ] || [ "$SUBAGENT_TYPE" = "Explore" ]; then
    cat <<EOF

┌─────────────────────────────────────────────────────────┐
│ 🔄 ROUTING NOTIFICATION                                 │
├─────────────────────────────────────────────────────────┤
│ Delegating to: $SUBAGENT_TYPE subagent
│ Reason: Task complexity requires optimization          │
│ Benefit: Reduced token consumption                     │
└─────────────────────────────────────────────────────────┘

EOF
fi

# Always allow the tool to proceed
exit 0
