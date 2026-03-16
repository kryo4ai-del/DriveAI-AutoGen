#!/bin/bash
# Golden Acceptance Gate Suite — AskFin Premium
# Run before any promotion/release decision.
#
# Exit 0 = ALL GATES PASSED → safe to promote
# Exit 1 = GATE FAILED → fix before promoting

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
RESULT_FILE="$PROJECT_DIR/scripts/golden_gate_result.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cd "$PROJECT_DIR"

echo "============================================"
echo "  AskFin Premium — Golden Acceptance Gates"
echo "  $(date)"
echo "============================================"
echo ""

# Gate 1: Build
echo "▶ Gate 1: Build..."
if xcodebuild -project AskFinPremium.xcodeproj \
  -scheme AskFinPremium \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build 2>&1 | grep -q "BUILD SUCCEEDED"; then
    echo "  ✅ Gate 1: Build PASSED"
    GATE1="PASSED"
else
    echo "  ❌ Gate 1: Build FAILED"
    GATE1="FAILED"
fi

# Gates 2-7: XCUITests
echo ""
echo "▶ Gates 2-7: XCUITests..."
TEST_OUTPUT=$(xcodebuild test \
  -project AskFinPremium.xcodeproj \
  -scheme AskFinUITests \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  2>&1)

TOTAL_TESTS=$(echo "$TEST_OUTPUT" | grep "Executed" | tail -1 | grep -oE '[0-9]+ tests' | head -1 | grep -oE '[0-9]+')
FAILURES=$(echo "$TEST_OUTPUT" | grep "Executed" | tail -1 | grep -oE '[0-9]+ failures' | head -1 | grep -oE '[0-9]+')

if echo "$TEST_OUTPUT" | grep -q "TEST SUCCEEDED"; then
    echo "  ✅ Gates 2-7: $TOTAL_TESTS tests, $FAILURES failures"
    GATES_27="PASSED"
else
    echo "  ❌ Gates 2-7: FAILED"
    echo "$TEST_OUTPUT" | grep "failed" | head -10
    GATES_27="FAILED"
fi

# Summary
echo ""
echo "============================================"
if [[ "$GATE1" == "PASSED" && "$GATES_27" == "PASSED" ]]; then
    echo "  🟢 ALL GOLDEN GATES PASSED"
    echo "  → Safe to promote / release"
    OVERALL="PASSED"
    EXIT_CODE=0
else
    echo "  🔴 GOLDEN GATES FAILED"
    echo "  → Fix before promoting"
    OVERALL="FAILED"
    EXIT_CODE=1
fi
echo "============================================"

# Save result
cat > "$RESULT_FILE" <<EOF
{
  "timestamp": "$TIMESTAMP",
  "overall": "$OVERALL",
  "gate1_build": "$GATE1",
  "gates27_tests": "$GATES_27",
  "total_tests": $TOTAL_TESTS,
  "failures": $FAILURES
}
EOF

echo ""
echo "Result saved: $RESULT_FILE"

exit $EXIT_CODE
