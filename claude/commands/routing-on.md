---
description: Re-enable automatic token routing for this session
allowed-tools: Bash, Write, Read
---

## Enable Token Routing

This command re-enables automatic token routing if it was previously disabled.

Execute these steps:

1. **Check if disabled**
   Check if the routing-disabled flag exists:
   ```bash
   ls ~/.claude/session-env/routing-disabled
   ```

2. **Remove session flag**
   If flag exists, remove it:
   ```bash
   rm -f ~/.claude/session-env/routing-disabled
   ```

3. **Confirm to user**
   ```
   ✅ Token routing ENABLED for this session

   What this means:
   - Automatic subagent delegation restored
   - Routing notifications active
   - Token optimization back in effect
   - Lower risk of rate limits

   To disable: Use /routing-off command
   ```

4. **If already enabled**
   If flag didn't exist, inform user:
   ```
   ℹ️  Token routing is already ENABLED

   The system is working normally with automatic optimization.
   ```
