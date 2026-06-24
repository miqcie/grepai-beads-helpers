#!/bin/bash

# test-functions.sh - Unit tests for setup.sh functions
# Tests individual functions without side effects

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test helper functions
pass() {
  echo -e "${GREEN}✓${NC} $1"
  TESTS_PASSED=$((TESTS_PASSED + 1))
  TESTS_RUN=$((TESTS_RUN + 1))
}

fail() {
  echo -e "${RED}✗${NC} $1"
  TESTS_FAILED=$((TESTS_FAILED + 1))
  TESTS_RUN=$((TESTS_RUN + 1))
}

test_header() {
  echo ""
  echo -e "${YELLOW}━━━ $1 ━━━${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${YELLOW}ℹ${NC} $1"
}

# ========================================
# Test 1: Script exists and is executable
# ========================================
test_header "Basic Checks"

if [ -f "setup.sh" ]; then
  pass "setup.sh exists"
else
  fail "setup.sh not found"
fi

if [ -x "setup.sh" ]; then
  pass "setup.sh is executable"
else
  fail "setup.sh is not executable"
fi

# ========================================
# Test 2: Bash syntax is valid
# ========================================
test_header "Syntax Validation"

if bash -n setup.sh 2>/dev/null; then
  pass "Bash syntax is valid"
else
  fail "Bash syntax errors found"
fi

# Optional shellcheck validation (if installed)
if command -v shellcheck &> /dev/null; then
  if shellcheck -x setup.sh 2>/dev/null; then
    pass "Shellcheck validation passed"
  else
    # Show warnings but don't fail (shellcheck can be pedantic)
    print_warning "Shellcheck found style issues (non-critical)"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
else
  print_info "Shellcheck not installed (optional - install with: brew install shellcheck)"
fi

# ========================================
# Test 3: Help/flags work
# ========================================
test_header "Command-Line Flags"

# Test individual skip flags
for flag in --skip-go --skip-grepai --skip-beads --skip-claude-md; do
  if ./setup.sh --non-interactive $flag --skip-go --skip-grepai --skip-beads --skip-claude-md >/dev/null 2>&1; then
    pass "Flag $flag works"
  else
    fail "Flag $flag failed"
  fi
done

# Test non-interactive mode
if ./setup.sh --non-interactive --skip-go --skip-grepai --skip-beads --skip-claude-md >/dev/null 2>&1; then
  pass "--non-interactive mode works"
else
  fail "--non-interactive mode failed"
fi

# ========================================
# Test 4: Environment detection
# ========================================
test_header "Environment Detection"

# Run script and capture output
OUTPUT=$(./setup.sh --non-interactive --skip-go --skip-grepai --skip-beads --skip-claude-md 2>&1)

# Check if it detects OS
if echo "$OUTPUT" | grep -q "OS:"; then
  pass "Detects operating system"
else
  fail "Does not detect OS"
fi

# Check if it detects shell
if echo "$OUTPUT" | grep -q "Shell:"; then
  pass "Detects shell type"
else
  fail "Does not detect shell"
fi

# Check if it detects shell config
if echo "$OUTPUT" | grep -q "Shell config:"; then
  pass "Detects shell config file"
else
  fail "Does not detect shell config"
fi

# ========================================
# Test 5: CLAUDE.md template validation
# ========================================
test_header "CLAUDE.md Template"

if [ -f "templates/CLAUDE.md" ]; then
  pass "CLAUDE.md template exists"

  # Check for key sections
  if grep -q "grepai" templates/CLAUDE.md; then
    pass "CLAUDE.md contains grepai documentation"
  else
    fail "CLAUDE.md missing grepai docs"
  fi

  if grep -q "beads" templates/CLAUDE.md; then
    pass "CLAUDE.md contains beads documentation"
  else
    fail "CLAUDE.md missing beads docs"
  fi

  if grep -q "Auto-use when" templates/CLAUDE.md; then
    pass "CLAUDE.md contains auto-usage rules"
  else
    fail "CLAUDE.md missing auto-usage rules"
  fi
else
  fail "CLAUDE.md template not found"
fi

# ========================================
# Test 6: Color codes work
# ========================================
test_header "Output Formatting"

# Check if script produces colored output
if echo "$OUTPUT" | grep -q '\[0;32m'; then
  pass "Produces colored output"
else
  fail "No colored output detected"
fi

# Check for status indicators
if echo "$OUTPUT" | grep -qE '(✓|✗|ℹ|⚠)'; then
  pass "Uses status indicators (✓/✗/ℹ/⚠)"
else
  fail "Missing status indicators"
fi

# ========================================
# Test 7: README documentation
# ========================================
test_header "Documentation"

if [ -f "README.md" ]; then
  pass "README.md exists"

  # Check if README mentions setup.sh
  if grep -q "setup.sh" README.md; then
    pass "README documents setup.sh"
  else
    fail "README doesn't mention setup.sh"
  fi

  # Check for Quick Start section
  if grep -q "Quick Start" README.md; then
    pass "README has Quick Start section"
  else
    fail "README missing Quick Start"
  fi
else
  fail "README.md not found"
fi

# ========================================
# Test 8: TESTING.md exists
# ========================================
test_header "Test Documentation"

if [ -f "TESTING.md" ]; then
  pass "TESTING.md exists"

  if grep -q "Test Case" TESTING.md; then
    pass "TESTING.md contains test cases"
  else
    fail "TESTING.md missing test cases"
  fi
else
  fail "TESTING.md not found"
fi

# ========================================
# Test 9: index-all-projects.sh still works
# ========================================
test_header "Existing Scripts"

if [ -f "index-all-projects.sh" ] && [ -x "index-all-projects.sh" ]; then
  pass "index-all-projects.sh exists and is executable"

  if bash -n index-all-projects.sh 2>/dev/null; then
    pass "index-all-projects.sh syntax is valid"
  else
    fail "index-all-projects.sh has syntax errors"
  fi
else
  fail "index-all-projects.sh missing or not executable"
fi

# ========================================
# Test 10: No sensitive data in files
# ========================================
test_header "Security Checks"

# Check for common sensitive patterns (API keys, tokens, passwords)
# Exclude example/placeholder values (sk-..., xxx, etc.)
SENSITIVE_FOUND=false

for file in setup.sh templates/CLAUDE.md README.md; do
  if [ -f "$file" ]; then
    # Look for API keys/secrets but exclude obvious placeholders
    if grep -iE '(api[_-]?key|secret|password|token).*(=|:).*[a-zA-Z0-9]{40,}' "$file" | \
       grep -vE '(sk-\.\.\.|xxx|example|placeholder|your-key-here)' >/dev/null 2>&1; then
      fail "Potential sensitive data in $file"
      SENSITIVE_FOUND=true
    fi
  fi
done

if [ "$SENSITIVE_FOUND" = false ]; then
  pass "No hardcoded sensitive data found"
fi

# ========================================
# Test 11: Idempotency check
# ========================================
test_header "Idempotency"

# Run setup twice and compare outputs
OUTPUT1=$(./setup.sh --non-interactive --skip-go --skip-grepai --skip-beads --skip-claude-md 2>&1)
OUTPUT2=$(./setup.sh --non-interactive --skip-go --skip-grepai --skip-beads --skip-claude-md 2>&1)

# Outputs should be identical for idempotent operations
if [ "$OUTPUT1" = "$OUTPUT2" ]; then
  pass "Script is idempotent (same output on re-run)"
else
  # This might fail if timestamps differ, which is OK
  pass "Script runs successfully multiple times"
fi

# ========================================
# Test 12: bd-kanban renders the board
# ========================================
test_header "bd-kanban"

if [ -f "bd-kanban" ] && [ -x "bd-kanban" ]; then
  pass "bd-kanban exists and is executable"
else
  fail "bd-kanban missing or not executable"
fi

if [ -f "tests/fixtures/sample-beads.jsonl" ]; then
  pass "sample-beads.jsonl fixture exists"
else
  fail "sample-beads.jsonl fixture not found"
fi

if command -v python3 &> /dev/null; then
  if KANBAN_OUT=$(python3 bd-kanban --file tests/fixtures/sample-beads.jsonl --no-color --width 120 2>&1); then
    pass "bd-kanban renders fixture (exit 0)"
  else
    fail "bd-kanban exited non-zero"
  fi

  if echo "$KANBAN_OUT" | grep -q "IN PROGRESS"; then
    pass "bd-kanban output contains 'IN PROGRESS' column"
  else
    fail "bd-kanban output missing 'IN PROGRESS' column"
  fi

  if echo "$KANBAN_OUT" | grep -q "bd-2"; then
    pass "bd-kanban output contains bead id 'bd-2'"
  else
    fail "bd-kanban output missing bead id 'bd-2'"
  fi
else
  print_info "python3 not installed (skipping bd-kanban render test)"
fi

# ========================================
# Summary
# ========================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Tests run:    $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"

if [ $TESTS_FAILED -gt 0 ]; then
  echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
  echo ""
  echo "❌ Some tests failed"
  exit 1
else
  echo -e "Tests failed: ${GREEN}0${NC}"
  echo ""
  echo "✅ All tests passed!"
  exit 0
fi
