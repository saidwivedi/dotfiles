#!/bin/bash

# Test script for token routing system
# Verifies all components are properly installed

echo "=================================="
echo "Token Routing System Test"
echo "=================================="
echo ""

PASS=0
FAIL=0

echo "Testing notification system components..."
echo ""

# Test 1: Check subagent file
echo "[TEST 1] Token-optimizer subagent..."
if [ -f ~/.claude/agents/token-optimizer.md ]; then
    echo "✓ PASS: Subagent file exists"
    PASS=$((PASS + 1))
else
    echo "✗ FAIL: Subagent file missing"
    FAIL=$((FAIL + 1))
fi

# Test 2: Check hook script
echo ""
echo "[TEST 2] Smart router hook..."
if [ -f ~/.claude/hooks/smart-router.sh ]; then
    if [ -x ~/.claude/hooks/smart-router.sh ]; then
        echo "✓ PASS: Hook script exists and is executable"
        PASS=$((PASS + 1))
    else
        echo "✗ FAIL: Hook script not executable"
        FAIL=$((FAIL + 1))
    fi
else
    echo "✗ FAIL: Hook script missing"
    FAIL=$((FAIL + 1))
fi

# Test 3: Check settings.json hook configuration
echo ""
echo "[TEST 3] Hook configuration..."
if grep -q "UserPromptSubmit" ~/.claude/settings.json 2>/dev/null; then
    echo "✓ PASS: Hook configured in settings.json"
    PASS=$((PASS + 1))
else
    echo "✗ FAIL: Hook not configured in settings.json"
    FAIL=$((FAIL + 1))
fi

# Test 4: Check verify commands
echo ""
echo "[TEST 4] Verify commands..."
if [ -f ~/.claude/commands/verify.md ] && [ -f ~/.claude/commands/verify-auto.md ]; then
    echo "✓ PASS: Both verify commands exist"
    PASS=$((PASS + 1))
else
    echo "✗ FAIL: Verify commands missing"
    FAIL=$((FAIL + 1))
fi

# Test 5: Check routing script
echo ""
echo "[TEST 5] Smart route script..."
if [ -f ~/.claude/scripts/smart-route.sh ]; then
    if [ -x ~/.claude/scripts/smart-route.sh ]; then
        echo "✓ PASS: Routing script exists and is executable"
        PASS=$((PASS + 1))
    else
        echo "✗ FAIL: Routing script not executable"
        FAIL=$((FAIL + 1))
    fi
else
    echo "✗ FAIL: Routing script missing"
    FAIL=$((FAIL + 1))
fi

# Test 6: Check verify_with_llm script
echo ""
echo "[TEST 6] Codex integration script..."
if [ -f ~/.claude/scripts/verify_with_llm.sh ]; then
    if [ -x ~/.claude/scripts/verify_with_llm.sh ]; then
        echo "✓ PASS: Codex script exists and is executable"
        PASS=$((PASS + 1))
    else
        echo "✗ FAIL: Codex script not executable"
        FAIL=$((FAIL + 1))
    fi
else
    echo "✗ FAIL: Codex script missing"
    FAIL=$((FAIL + 1))
fi

# Test 7: Check codex CLI availability
echo ""
echo "[TEST 7] Codex CLI availability..."
if command -v codex &> /dev/null; then
    echo "✓ PASS: Codex CLI found"
    PASS=$((PASS + 1))
else
    echo "⚠ WARNING: Codex CLI not found (needed for /verify)"
    echo "  External routing will not work without codex CLI"
fi

# Test 8: Functional test of smart-route.sh
echo ""
echo "[TEST 8] Routing logic test..."
ROUTE_OUTPUT=$(~/.claude/scripts/smart-route.sh "comprehensive architectural analysis across 100 files" 80000 2>/dev/null)
if echo "$ROUTE_OUTPUT" | grep -q "codex-external\|token-optimizer"; then
    echo "✓ PASS: Routing logic working correctly"
    echo "  Output: $(echo "$ROUTE_OUTPUT" | head -1)"
    PASS=$((PASS + 1))
else
    echo "✗ FAIL: Routing logic not working as expected"
    FAIL=$((FAIL + 1))
fi

# Test 9: Hook pattern matching test
echo ""
echo "[TEST 9] Hook pattern detection..."
TEST_PROMPT='{"prompt":"comprehensive review of all files"}'
HOOK_OUTPUT=$(echo "$TEST_PROMPT" | ~/.claude/hooks/smart-router.sh 2>/dev/null)
if echo "$HOOK_OUTPUT" | grep -q "TOKEN OPTIMIZATION"; then
    echo "✓ PASS: Hook pattern detection working"
    PASS=$((PASS + 1))
else
    echo "✗ FAIL: Hook pattern detection not working"
    FAIL=$((FAIL + 1))
fi

# Test 10: Subagent notifier hook
echo ""
echo "[TEST 10] Subagent notification hook..."
if [ -f ~/.claude/hooks/subagent-notifier.sh ]; then
    if [ -x ~/.claude/hooks/subagent-notifier.sh ]; then
        echo "✓ PASS: Subagent notifier exists and is executable"
        PASS=$((PASS + 1))
    else
        echo "✗ FAIL: Subagent notifier not executable"
        FAIL=$((FAIL + 1))
    fi
else
    echo "✗ FAIL: Subagent notifier missing"
    FAIL=$((FAIL + 1))
fi

# Test 11: PreToolUse hook configured
echo ""
echo "[TEST 11] PreToolUse hook configuration..."
if grep -q "PreToolUse" ~/.claude/settings.json 2>/dev/null; then
    echo "✓ PASS: PreToolUse hook configured"
    PASS=$((PASS + 1))
else
    echo "✗ FAIL: PreToolUse hook not configured"
    FAIL=$((FAIL + 1))
fi

# Test 12: Subagent announcement configured
echo ""
echo "[TEST 12] Subagent self-announcement..."
if grep -q "IMPORTANT: Announce Your Activation" ~/.claude/agents/token-optimizer.md 2>/dev/null; then
    echo "✓ PASS: Subagent configured to announce activation"
    PASS=$((PASS + 1))
else
    echo "✗ FAIL: Subagent missing announcement section"
    FAIL=$((FAIL + 1))
fi

# Test 13: Control commands exist
echo ""
echo "[TEST 13] Routing control commands..."
if [ -f ~/.claude/commands/routing-off.md ] && \
   [ -f ~/.claude/commands/routing-on.md ] && \
   [ -f ~/.claude/commands/routing-status.md ]; then
    echo "✓ PASS: All routing control commands exist"
    PASS=$((PASS + 1))
else
    echo "✗ FAIL: Missing routing control commands"
    FAIL=$((FAIL + 1))
fi

# Test 14: Hooks check for disabled flag
echo ""
echo "[TEST 14] Hooks check routing-disabled flag..."
if grep -q "routing-disabled" ~/.claude/hooks/smart-router.sh && \
   grep -q "routing-disabled" ~/.claude/hooks/subagent-notifier.sh; then
    echo "✓ PASS: Hooks properly check for disabled flag"
    PASS=$((PASS + 1))
else
    echo "✗ FAIL: Hooks don't check for disabled flag"
    FAIL=$((FAIL + 1))
fi

# Test 15: Subagent description includes disable check
echo ""
echo "[TEST 15] Subagent respects routing-disabled..."
if grep -q "DO NOT USE if.*routing-disabled" ~/.claude/agents/token-optimizer.md; then
    echo "✓ PASS: Subagent configured to respect disabled flag"
    PASS=$((PASS + 1))
else
    echo "✗ FAIL: Subagent missing disable check"
    FAIL=$((FAIL + 1))
fi

# Summary
echo ""
echo "=================================="
echo "Test Summary"
echo "=================================="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "✓ All tests passed! Token routing system is ready."
    echo ""
    echo "Try these commands:"
    echo "  • Regular tasks work as before"
    echo "  • /verify for external Codex review"
    echo "  • /verify-auto for smart routing"
    exit 0
else
    echo "✗ Some tests failed. Please review the output above."
    exit 1
fi
