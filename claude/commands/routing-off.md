---
description: Disable automatic token routing for this session
allowed-tools: Bash, Write, Read
---

## Disable Token Routing

This command temporarily disables automatic token routing for the current session.

**What gets disabled:**
- Token-optimizer subagent auto-invocation
- Pattern detection notifications
- Routing suggestions

**What still works:**
- Manual /verify command (you can still use it explicitly)
- All normal Claude Code functionality

Execute these steps:

1. **Inform the user**
   ```
   Disabling automatic token routing for this session...
   ```

2. **Set session flag**
   Create a temporary flag file:
   ```bash
   touch ~/.claude/session-env/routing-disabled
   ```

3. **Confirm to user**
   ```
   ✅ Token routing DISABLED for this session

   What this means:
   - No automatic subagent delegation
   - No routing notifications
   - All tasks handled by main Claude Code thread
   - Higher token consumption (may hit rate limits)

   To re-enable: Use /routing-on command
   Manual /verify still available if needed
   ```

4. **Important reminder**
   Remind the user that this increases token consumption and rate limit risk.
