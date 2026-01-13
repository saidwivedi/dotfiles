---
description: Check current token routing status
allowed-tools: Bash
---

## Check Token Routing Status

This command shows the current state of token routing for this session.

Execute these steps:

1. **Check session flag**
   ```bash
   if [ -f ~/.claude/session-env/routing-disabled ]; then
       echo "DISABLED"
   else
       echo "ENABLED"
   fi
   ```

2. **Display status to user**

   If ENABLED:
   ```
   🟢 Token Routing: ENABLED

   Active features:
   ✓ Automatic subagent delegation
   ✓ Pattern detection notifications
   ✓ Token optimization
   ✓ Routing suggestions

   Commands:
   - /routing-off - Disable routing
   - /verify - Manual Codex routing
   - /verify-auto - Smart Codex routing
   ```

   If DISABLED:
   ```
   🔴 Token Routing: DISABLED

   Current mode:
   ✗ No automatic subagent delegation
   ✗ No routing notifications
   ✗ All tasks handled by main thread
   ⚠️  Higher token consumption

   Commands:
   - /routing-on - Re-enable routing
   - /verify - Manual Codex routing (still available)
   ```

3. **Show configuration info**
   ```
   Configuration:
   - Subagent: token-optimizer
   - Hooks: UserPromptSubmit, PreToolUse
   - Session flag: ~/.claude/session-env/routing-disabled

   Documentation: ~/Work/routing-notifications-guide.md
   ```
