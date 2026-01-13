---
description: Create verification summary, get external LLM verification, wait for results
allowed-tools: Bash(*), Write, Read
---

## Verification Workflow

Execute these steps:

1. **Summarize Current Conversation**
   - Review the entire conversation history
   - Identify the problem we've been discussing
   - Document the solution we agreed upon
   - Include key decisions and reasoning

2. **Create Verification Summary File**
   - Generate filename with topic and timestamp: `verify_{topic}_{YYYYMMDD_HHMMSS}.md`
   - Determine location: current directory if git repo exists, otherwise ~/Work
   - Write a clear summary containing:
     * Problem statement
     * Proposed solution
     * Why this approach was chosen
     * Any constraints or requirements discussed

3. **Invoke External Verification**
   - Call the verification script: `~/.claude/scripts/verify_with_llm.sh`
   - Pass: topic, summary file path, and current working directory
   - Codex will read the summary and examine the codebase if needed
   - Codex creates verification report: `verify_{topic}_{timestamp}_report.md`
   - Wait for report file to be created (script handles polling)

4. **Critically Analyze Verification Report**
   - Read the verification report
   - **DO NOT blindly accept Codex's feedback**
   - For each issue raised by Codex, analyze:
     * Is this a critical bug that breaks functionality?
     * Is this an accessibility/UX concern with clear impact?
     * Is this a debatable design choice that's subjective?
     * Does the suggestion align with the original design goals?
   - Categorize issues as:
     * ✓ VALID - Codex is correct, should be fixed
     * ⚠️ DEBATABLE - Subjective, needs user decision
     * ✗ INCORRECT - Codex misunderstood or wrong

5. **Present Analysis to User**
   - Show Codex's verdict (APPROVED/NEEDS_REVIEW/REJECTED)
   - Present each issue with YOUR critical analysis
   - Explain why you agree or disagree with each point
   - Provide reasoning for your assessment
   - **Ask user for approval before implementing ANY changes**
   - Let user decide which changes to make

6. **Implement Only Approved Changes**
   - Only implement changes the user approves
   - Skip or adjust changes user rejects or questions
   - Document what was implemented and what was skipped

Execute this workflow completely. Focus on conversation content, not code changes.
CRITICAL: Never auto-implement Codex suggestions without user approval.
