#!/bin/bash

# Arguments: topic, summary_file_path, working_directory
TOPIC=${1:-"solution"}
SUMMARY_FILE=${2}
WORKING_DIR=${3:-$(pwd)}

if [ -z "$SUMMARY_FILE" ] || [ ! -f "$SUMMARY_FILE" ]; then
    echo "Error: Summary file not provided or doesn't exist"
    exit 1
fi

# Extract directory and base name for report
DIR=$(dirname "$SUMMARY_FILE")
BASE=$(basename "$SUMMARY_FILE" .md)
REPORT_PATH="${DIR}/${BASE}_report.md"

echo "Invoking codex for verification..."
echo "Summary: $SUMMARY_FILE"
echo "Working directory: $WORKING_DIR"
echo "Report will be created at: $REPORT_PATH"

# Call codex exec with instruction to verify the solution and write output to report file
cd "$WORKING_DIR"
codex exec "Please read the file at $SUMMARY_FILE. It contains a problem statement and proposed solution from a brainstorming session.

You can examine the codebase in this directory if needed to verify the solution.

Verify if the solution is correct and feasible. Create a verification report with:
1) Problem understanding
2) Solution analysis
3) Potential issues or concerns (be specific with file paths and line numbers)
4) For each concern, explain:
   - Why this is an issue
   - Impact on functionality, UX, or accessibility
   - Whether it's a critical bug, minor issue, or debatable design choice
5) Verdict (APPROVED/NEEDS_REVIEW/REJECTED)

IMPORTANT: Distinguish between:
- Critical bugs that will break functionality
- Accessibility/UX issues that harm user experience
- Debatable design choices that are subjective

Look at the codebase if necessary to validate the proposed approach." -o "$REPORT_PATH"

# Check if report was created
if [ -f "$REPORT_PATH" ]; then
    echo ""
    echo "Verification complete!"
    echo "Report: $REPORT_PATH"
    exit 0
else
    echo "Error: Verification report not created"
    exit 1
fi
