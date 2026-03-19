#!/bin/bash
# GSD Antigravity — E2E Smoke Test
# Validates that the full pipeline works: init → plan → execute → summary
# Usage: bash tests/smoke-test.sh

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

GSD_TOOLS="$HOME/.gemini/antigravity/get-shit-done/bin/gsd-tools.cjs"
TEST_DIR=$(mktemp -d /tmp/gsd-smoke-XXXX)
PASS=0
FAIL=0

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL + 1)); }
check() { if [ $? -eq 0 ]; then pass "$1"; else fail "$1"; fi; }

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " GSD Antigravity — Smoke Test"
echo " Test dir: $TEST_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check prerequisites
echo ""
echo "Prerequisites:"
[ -f "$GSD_TOOLS" ]; check "gsd-tools.cjs exists"
node "$GSD_TOOLS" init new-project > /dev/null 2>&1; check "gsd-tools.cjs is executable"

# Setup test project
cd "$TEST_DIR"
git init -q

# 1. new-project flow
echo ""
echo "new-project:"
mkdir -p .planning
cp "$HOME/.gemini/antigravity/get-shit-done/templates/config.json" .planning/config.json
[ -f .planning/config.json ]; check "config.json created"
grep -q '"antigravity"' .planning/config.json; check "config.json has runtime=antigravity"
grep -q '"enabled": false' .planning/config.json; check "parallelization disabled"

cat > .planning/PROJECT.md << 'EOF'
# Smoke Test Project
## Vision
Validate GSD Antigravity works end-to-end.
EOF
[ -f .planning/PROJECT.md ]; check "PROJECT.md created"

cat > .planning/REQUIREMENTS.md << 'EOF'
# Requirements
## P0
- [REQ-01] Print hello
EOF

cat > .planning/ROADMAP.md << 'EOF'
# Roadmap — v1.0
| # | Phase | Goal | Status |
|---|-------|------|--------|
| 1 | Hello | Print hello | Not Started |
EOF

cat > .planning/STATE.md << 'EOF'
# State
## Current Position
Phase 1
EOF

git add -A && git commit -q -m "init"
INIT_JSON=$(node "$GSD_TOOLS" init new-project 2>&1)
echo "$INIT_JSON" | grep -q '"planning_exists": true'; check "init new-project detects .planning/"

# 2. plan-phase flow
echo ""
echo "plan-phase:"
mkdir -p .planning/phases/01-hello
PLAN_JSON=$(node "$GSD_TOOLS" init plan-phase 1 2>&1)
echo "$PLAN_JSON" | grep -q '"phase_found": true'; check "init plan-phase finds phase dir"

cat > .planning/phases/01-hello/01-01-PLAN.md << 'EOF'
---
phase: 1
plan: 1
name: Hello Task
---
# Plan 1
<tasks>
<task id="1" type="auto" name="Create file">
<action>Create hello.txt</action>
</task>
</tasks>
EOF
git add -A && git commit -q -m "plan"
PLAN_JSON2=$(node "$GSD_TOOLS" init plan-phase 1 2>&1)
echo "$PLAN_JSON2" | grep -q '"has_plans": true'; check "plan-phase detects PLAN.md"
echo "$PLAN_JSON2" | grep -q '"plan_count": 1'; check "plan_count = 1"

# 3. execute-phase flow
echo ""
echo "execute-phase:"
EXEC_JSON=$(node "$GSD_TOOLS" init execute-phase 1 2>&1)
echo "$EXEC_JSON" | grep -q '"phase_found": true'; check "init execute-phase finds phase"
echo "$EXEC_JSON" | grep -q '"incomplete_count": 1'; check "1 incomplete plan detected"
echo "$EXEC_JSON" | grep -q '"parallelization": false'; check "parallelization=false in exec"

# Execute the task
echo "hello" > hello.txt
git add hello.txt && git commit -q -m "feat(01-01): create hello.txt"
[ -f hello.txt ]; check "hello.txt created"

# Create summary
cat > .planning/phases/01-hello/01-01-SUMMARY.md << 'EOF'
---
phase: 1
plan: 1
name: Hello Task
---
# Summary
Done.
EOF
git add -A && git commit -q -m "docs(01-01): summary"

# 4. Post-execute tools  
echo ""
echo "post-execute:"
ROADMAP_JSON=$(node "$GSD_TOOLS" roadmap update-plan-progress 1 2>&1)
echo "$ROADMAP_JSON" | grep -q '"updated": true'; check "roadmap update-plan-progress works"
echo "$ROADMAP_JSON" | grep -q '"status": "Complete"'; check "phase marked Complete"

COMMIT_JSON=$(node "$GSD_TOOLS" commit "test commit" --files .planning/ROADMAP.md 2>&1)
echo "$COMMIT_JSON" | grep -q '"committed": true'; check "gsd-tools commit works"

# 5. Verify installed files
echo ""
echo "installed files:"
[ -f "$HOME/.gemini/antigravity/get-shit-done/references/antigravity-tools.md" ]; check "antigravity-tools.md reference exists"
[ -d "$HOME/.gemini/antigravity/skills/gsd-new-project" ]; check "gsd-new-project skill dir exists"
[ -d "$HOME/.gemini/antigravity/skills/gsd-execute-phase" ]; check "gsd-execute-phase skill dir exists"
grep -q "antigravity_compatibility\|GEMINI.md\|view_file" "$HOME/.gemini/antigravity/get-shit-done/workflows/execute-plan.md"; check "execute-plan.md has Antigravity adaptations"

# Cleanup
rm -rf "$TEST_DIR"

# Results
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TOTAL=$((PASS + FAIL))
if [ $FAIL -eq 0 ]; then
  echo -e " ${GREEN}ALL $TOTAL TESTS PASSED${NC}"
else
  echo -e " ${RED}$FAIL FAILED${NC} / $TOTAL total"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
exit $FAIL
