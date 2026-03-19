#!/usr/bin/env bash
# repo-audit.sh — Stage 3 Reflection automated audit script
# Usage: ./scripts/repo-audit.sh [path-to-repo] [--privacy]
# If no path given, audits the current directory.
# --privacy: Run enhanced privacy scan (Stage 3.5)

set -uo pipefail

REPO_PATH="${1:-.}"
PRIVACY_MODE="${2:-}"

PASS=0
WARN=0
FAIL=0

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

pass() { echo -e "${GREEN}[PASS]${NC} $1"; ((PASS++)); }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; ((WARN++)); }
fail() { echo -e "${RED}[FAIL]${NC} $1"; ((FAIL++)); }

echo "================================================"
echo " GitHub Repo Commander — Stage 3/3.5 Audit"
echo " Target: $REPO_PATH"
if [ "$PRIVACY_MODE" = "--privacy" ]; then
  echo " Mode: Enhanced Privacy Scan (Stage 3.5)"
fi
echo "================================================"
echo ""

cd "$REPO_PATH"

# ── 1. Hardcoded Secrets ─────────────────────────────────────────────────────
echo "[ 1/7 ] Scanning for hardcoded secrets..."

# Enhanced secret patterns (v4.2.0)
SECRET_PATTERNS="\
ghp_[A-Za-z0-9_]{36}|\
gho_[A-Za-z0-9_]{36}|\
ghu_[A-Za-z0-9_]{36}|\
ghs_[A-Za-z0-9_]{36}|\
ghr_[A-Za-z0-9_]{36}|\
ghu_[A-Za-z0-9_]{36}|\
sk-[A-Za-z0-9]{20,}|\
sk_live_[A-Za-z0-9]{24,}|\
api_key|\
apikey|\
api-key|\
password|\
passwd|\
pwd|\
secret|\
SECRET|\
private_key|\
PRIVATE_KEY|\
access_token|\
ACCESS_TOKEN|\
auth_token|\
AUTH_TOKEN|\
bearer|\
BEARER|\
oauth|\
OAUTH|\
APP_SECRET|\
APP_ID|\
secret_key|\
SECRET_KEY"

HITS=$(grep -rn --include="*.py" --include="*.js" --include="*.ts" \
  --include="*.yaml" --include="*.yml" --include="*.json" --include="*.env" \
  --include="*.sh" --include="*.bash" --include="*.zsh" \
  --include="*.md" --include="*.txt" --include="*.cfg" --include="*.ini" \
  --exclude-dir=".git" --exclude-dir="node_modules" --exclude-dir="workflows" \
  -E "$SECRET_PATTERNS" . 2>/dev/null | grep -v "example\|placeholder\|YOUR_\|<.*>\|SECRET_PATTERNS\|grep\|***REMOVED***\|<redacted>\|workflow.md\|SKILL.md\|privacy-check.sh\|repo-audit.sh\|validate.yml" || true)

if [ -z "$HITS" ]; then
  pass "No hardcoded secrets detected"
else
  fail "Potential hardcoded secrets found:"
  echo "$HITS" | head -10
fi

# ── 2. .gitignore Coverage ───────────────────────────────────────────────────
echo ""
echo "[ 2/7 ] Checking .gitignore coverage..."
if [ ! -f ".gitignore" ]; then
  fail ".gitignore file is missing"
else
  MISSING_RULES=()
  for pattern in "node_modules" "__pycache__" ".env" "*.pyc" "*.orig" ".DS_Store"; do
    grep -q "$pattern" .gitignore || MISSING_RULES+=("$pattern")
  done
  if [ ${#MISSING_RULES[@]} -eq 0 ]; then
    pass ".gitignore covers all common patterns"
  else
    warn ".gitignore missing rules for: ${MISSING_RULES[*]}"
  fi
fi

# ── 3. Empty Directories ─────────────────────────────────────────────────────
echo ""
echo "[ 3/7 ] Checking for empty directories..."
EMPTY_DIRS=$(find . -type d -empty -not -path "./.git/*" 2>/dev/null || true)
if [ -z "$EMPTY_DIRS" ]; then
  pass "No empty directories found"
else
  warn "Empty directories found:"
  echo "$EMPTY_DIRS"
fi

# ── 4. Large Files ───────────────────────────────────────────────────────────
echo ""
echo "[ 4/7 ] Checking for large files (>1MB)..."
LARGE_FILES=$(find . -size +1M -not -path "./.git/*" -not -path "*/node_modules/*" 2>/dev/null || true)
if [ -z "$LARGE_FILES" ]; then
  pass "No large files (>1MB) found"
else
  warn "Large files detected (consider adding to .gitignore):"
  echo "$LARGE_FILES"
fi

# ── 5. node_modules in Git ───────────────────────────────────────────────────
echo ""
echo "[ 5/7 ] Checking for committed node_modules..."
if git ls-files | grep -q "node_modules/" 2>/dev/null; then
  fail "node_modules/ is tracked by git — run: git rm -r --cached node_modules/"
else
  pass "node_modules/ is not tracked by git"
fi

# ── 6. Broken README Links ───────────────────────────────────────────────────
echo ""
echo "[ 6/7 ] Checking README for broken internal links..."
if [ -f "README.md" ]; then
  BROKEN=0
  while IFS= read -r link; do
    # Extract path from markdown link [text](path)
    path=$(echo "$link" | sed 's/.*](\([^)]*\)).*/\1/' | sed 's/#.*//')
    if [[ "$path" != http* ]] && [[ -n "$path" ]] && [ ! -e "$path" ]; then
      warn "Broken link in README.md: $path"
      ((BROKEN++))
    fi
  done < <(grep -oE '\[[^]]+\]\([^)]+\)' README.md 2>/dev/null || true)
  [ "$BROKEN" -eq 0 ] && pass "No broken internal links in README.md"
else
  warn "README.md not found"
fi

# ── 7. Script Executability ──────────────────────────────────────────────────
echo ""
echo "[ 7/7 ] Checking script executability..."
NON_EXEC=$(find . -name "*.sh" -not -perm /111 -not -path "./.git/*" 2>/dev/null || true)
if [ -z "$NON_EXEC" ]; then
  pass "All .sh scripts are executable"
else
  warn "Non-executable scripts found (run chmod +x):"
  echo "$NON_EXEC"
fi

# ── Stage 3.5: Enhanced Privacy Scan ─────────────────────────────────────────
if [ "$PRIVACY_MODE" = "--privacy" ]; then
  echo ""
  echo "================================================"
  echo " Stage 3.5: Enhanced Privacy Scan"
  echo "================================================"
  echo ""
  
  # ── 8. GitHub Tokens ────────────────────────────────────────────────────────
  echo "[ 8/12 ] Scanning for GitHub tokens..."
  GH_TOKENS=$(grep -rn --include="*.sh" --include="*.py" --include="*.js" --include="*.yaml" \
    --include="*.yml" --include="*.json" --include="*.md" --include="*.env" \
    --exclude-dir=".git" --exclude-dir="node_modules" \
    -E "ghp_[A-Za-z0-9_]{36}|gho_[A-Za-z0-9_]{36}|ghu_[A-Za-z0-9_]{36}|ghs_[A-Za-z0-9_]{36}|ghr_[A-Za-z0-9_]{36}" \
    . 2>/dev/null || true)
  
  if [ -z "$GH_TOKENS" ]; then
    pass "No GitHub tokens found"
  else
    fail "GitHub tokens detected:"
    echo "$GH_TOKENS"
  fi
  
  # ── 9. Database URLs ───────────────────────────────────────────────────────
  echo ""
  echo "[ 9/12 ] Scanning for database URLs..."
  DB_URLS=$(grep -rn --include="*.sh" --include="*.py" --include="*.js" --include="*.yaml" \
    --include="*.yml" --include="*.json" --include="*.env" \
    --exclude-dir=".git" --exclude-dir="node_modules" \
    -E "mongodb://|postgres://|mysql://|redis://|postgresql://" \
    . 2>/dev/null | grep -v "example\|placeholder\|localhost\|127.0.0.1" || true)
  
  if [ -z "$DB_URLS" ]; then
    pass "No database URLs found"
  else
    warn "Database URLs detected (verify they are examples):"
    echo "$DB_URLS"
  fi
  
  # ── 10. Private Keys ────────────────────────────────────────────────────────
  echo ""
  echo "[ 10/12 ] Scanning for private keys..."
  PRIV_KEYS=$(grep -rn --include="*.pem" --include="*.key" --include="*.sh" --include="*.py" \
    --include="*.js" --include="*.yaml" --include="*.yml" --include="*.json" \
    --exclude-dir=".git" --exclude-dir="node_modules" \
    -E "-----BEGIN.*PRIVATE KEY-----|-----BEGIN RSA PRIVATE KEY-----|-----BEGIN EC PRIVATE KEY-----" \
    . 2>/dev/null || true)
  
  if [ -z "$PRIV_KEYS" ]; then
    pass "No private keys found"
  else
    fail "Private keys detected:"
    echo "$PRIV_KEYS"
  fi
  
  # ── 11. Email Addresses ────────────────────────────────────────────────────
  echo ""
  echo "[ 11/12 ] Scanning for personal email addresses..."
  PERSONAL_EMAILS=$(grep -rn --include="*.sh" --include="*.py" --include="*.js" --include="*.yaml" \
    --include="*.yml" --include="*.json" --include="*.md" --include="*.env" \
    --exclude-dir=".git" --exclude-dir="node_modules" \
    -E "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" \
    . 2>/dev/null | grep -v "example.com\|test.com\|placeholder\|noreply\|github.com\|users.noreply" || true)
  
  if [ -z "$PERSONAL_EMAILS" ]; then
    pass "No personal email addresses found"
  else
    warn "Potential personal email addresses detected (verify they are not sensitive):"
    echo "$PERSONAL_EMAILS" | head -5
  fi
  
  # ── 12. IP Addresses ───────────────────────────────────────────────────────
  echo ""
  echo "[ 12/12 ] Scanning for IP addresses..."
  IP_ADDRS=$(grep -rn --include="*.sh" --include="*.py" --include="*.js" --include="*.yaml" \
    --include="*.yml" --include="*.json" --include="*.md" --include="*.env" \
    --exclude-dir=".git" --exclude-dir="node_modules" \
    -E "([0-9]{1,3}\.){3}[0-9]{1,3}" \
    . 2>/dev/null | grep -v "127.0.0.1\|0.0.0.0\|255.255.255.255\|example" || true)
  
  if [ -z "$IP_ADDRS" ]; then
    pass "No suspicious IP addresses found"
  else
    warn "IP addresses detected (verify they are not internal):"
    echo "$IP_ADDRS" | head -5
  fi
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "================================================"
echo " Audit Summary"
echo "================================================"
echo -e " ${GREEN}PASS${NC}: $PASS"
echo -e " ${YELLOW}WARN${NC}: $WARN"
echo -e " ${RED}FAIL${NC}: $FAIL"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}Action required: $FAIL critical issue(s) must be fixed before committing.${NC}"
  echo -e "${BLUE}Tip: Run './scripts/repo-audit.sh --privacy' for enhanced privacy scan${NC}"
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo -e "${YELLOW}Review recommended: $WARN warning(s) found.${NC}"
  echo -e "${BLUE}Tip: Run './scripts/repo-audit.sh --privacy' for enhanced privacy scan${NC}"
  exit 0
else
  echo -e "${GREEN}All checks passed. Safe to proceed to Stage 4.${NC}"
  exit 0
fi
