---
description: Automatically route to Codex for verification of token-heavy tasks
allowed-tools: Bash(*), Write, Read, Grep, Glob
---

## Auto-Verification Workflow

This command intelligently determines if external Codex verification is needed based on:
- Number of files involved (>15 files = auto-route)
- Complexity of changes (architectural, multi-module = auto-route)
- User preference (explicit request)

Execute these steps:

1. **Analyze Current Task Scope**
   - Use Glob to count affected files
   - Use Grep to estimate code churn
   - Assess complexity: architectural vs. targeted changes

2. **Routing Decision**
   - If scope is SMALL (<10 files, single module):
     → Continue in Claude Code, no external routing needed

   - If scope is MEDIUM (10-20 files, 2-3 modules):
     → Ask user: "This is a medium-complexity task. Route to Codex? (Y/n)"

   - If scope is LARGE (>20 files, architectural):
     → Auto-route to Codex with notification
     → "Task complexity detected: routing to Codex for comprehensive analysis"

3. **Execute Verification (if routing to Codex)**
   - Create summary file as in /verify command
   - Call ~/.claude/scripts/verify_with_llm.sh
   - Wait for and analyze report
   - Present findings to user

4. **Present Results**
   - Show verification verdict
   - Highlight critical issues
   - Provide your critical analysis
   - Ask user for approval before implementing changes

This command provides smarter routing than manual /verify.
