#!/usr/bin/env bash
# privacy-check.sh — Stage 3.5 Enhanced Privacy Scan
# Usage: ./scripts/privacy-check.sh [path-to-repo]
# If no path given, scans the current directory.

set -uo pipefail

REPO_PATH="${1:-.}"
PASS=0
WARN=0
FAIL=0

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

pass() { echo -e "${GREEN}[PASS]${NC} $1"; ((PASS++)); }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; ((WARN++)); }
fail() { echo -e "${RED}[FAIL]${NC} $1"; ((FAIL++)); }

echo "================================================"
echo " Privacy Information Cleanup Scan (Stage 3.5)"
echo " Target: $REPO_PATH"
echo "================================================"
echo ""

cd "$REPO_PATH"

# ── 1. GitHub Tokens ────────────────────────────────────────────────────────
echo "[ 1/10 ] Scanning for GitHub tokens..."
GH_TOKENS=$(grep -rn --include="*.sh" --include="*.py" --include="*.js" --include="*.yaml" \
  --include="*.yml" --include="*.json" --include="*.md" --include="*.env" --include="*.txt" \
  --exclude-dir=".git" --exclude-dir="node_modules" --exclude-dir="workflows" \
  -E "ghp_[A-Za-z0-9_]{36}|gho_[A-Za-z0-9_]{36}|ghu_[A-Za-z0-9_]{36}|ghs_[A-Za-z0-9_]{36}|ghr_[A-Za-z0-9_]{36}" \
  . 2>/dev/null | grep -v "privacy-check.sh\|repo-audit.sh\|workflow.md\|SKILL.md\|validate.yml" || true)

if [ -z "$GH_TOKENS" ]; then
  pass "No GitHub tokens found"
else
  fail "GitHub tokens detected (CRITICAL):"
  echo "$GH_TOKENS"
fi

# ── 2. API Keys ─────────────────────────────────────────────────────────────
echo ""
echo "[ 2/10 ] Scanning for API keys..."
API_KEYS=$(grep -rn --include="*.sh" --include="*.py" --include="*.js" --include="*.yaml" \
  --include="*.yml" --include="*.json" --include="*.md" --include="*.env" --include="*.txt" \
  --exclude-dir=".git" --exclude-dir="node_modules" --exclude-dir="workflows" \
  -E "sk-[A-Za-z0-9]{20,}|sk_live_[A-Za-z0-9]{24,}" \
  . 2>/dev/null | grep -v "privacy-check.sh\|repo-audit.sh\|workflow.md\|SKILL.md\|validate.yml" || true)

if [ -z "$API_KEYS" ]; then
  pass "No API keys found"
else
  fail "API keys detected (CRITICAL):"
  echo "$API_KEYS"
fi

# ── 3. Passwords ─────────────────────────────────────────────────────────────
echo ""
echo "[ 3/10 ] Scanning for passwords..."
PASSWORDS=$(grep -rn --include="*.sh" --include="*.py" --include="*.js" --include="*.yaml" \
  --include="*.yml" --include="*.json" --include="*.env" --include="*.cfg" --include="*.ini" \
  --exclude-dir=".git" --exclude-dir="node_modules" \
  -E "password[[:space:]]*=[[:space:]]*['\"][^'\"]+['\"]|passwd[[:space:]]*=[[:space:]]*['\"][^'\"]+['\"]|pwd[[:space:]]*=[[:space:]]*['\"][^'\"]+['\"]" \
  . 2>/dev/null | grep -v "privacy-check.sh\|repo-audit.sh\|workflow.md\|SKILL.md\|validate.yml\|example\|test\|sample" || true)

if [ -z "$PASSWORDS" ]; then
  pass "No passwords found"
else
  fail "Passwords detected (CRITICAL):"
  echo "$PASSWORDS"
fi

# ── 4. Secrets ───────────────────────────────────────────────────────────────
echo ""
echo "[ 4/10 ] Scanning for secrets..."
SECRETS=$(grep -rn --include="*.sh" --include="*.py" --include="*.js" --include="*.yaml" \
  --include="*.yml" --include="*.json" --include="*.env" \
  --exclude-dir=".git" --exclude-dir="node_modules" \
  -E "APP_SECRET|SECRET_KEY|secret_key|private_key|access_token|auth_token" \
  . 2>/dev/null | grep -v "example\|placeholder\|YOUR_\|***REMOVED***" || true)

if [ -z "$SECRETS" ]; then
  pass "No secrets found"
else
  fail "Secrets detected (CRITICAL):"
  echo "$SECRETS"
fi

# ── 5. Database URLs ────────────────────────────────────────────────────────
echo ""
echo "[ 5/10 ] Scanning for database URLs..."
DB_URLS=$(grep -rn --include="*.sh" --include="*.py" --include="*.js" --include="*.yaml" \
  --include="*.yml" --include="*.json" --include="*.env" \
  --exclude-dir=".git" --exclude-dir="node_modules" \
  -E "mongodb://|postgres://|mysql://|redis://|postgresql://" \
  . 2>/dev/null | grep -v "privacy-check.sh\|repo-audit.sh\|workflow.md\|SKILL.md\|validate.yml\|example\|placeholder\|localhost\|127.0.0.1\|0.0.0.0" || true)

if [ -z "$DB_URLS" ]; then
  pass "No database URLs found"
else
  warn "Database URLs detected (HIGH):"
  echo "$DB_URLS"
fi

# ── 6. Private Keys ─────────────────────────────────────────────────────────
echo ""
echo "[ 6/10 ] Scanning for private keys..."
PRIV_KEYS=$(grep -rn --include="*.pem" --include="*.key" --include="*.sh" --include="*.py" \
  --include="*.js" --include="*.yaml" --include="*.yml" --include="*.json" \
  --exclude-dir=".git" --exclude-dir="node_modules" \
  -E "-----BEGIN.*PRIVATE KEY-----|-----BEGIN RSA PRIVATE KEY-----|-----BEGIN EC PRIVATE KEY-----" \
  . 2>/dev/null || true)

if [ -z "$PRIV_KEYS" ]; then
  pass "No private keys found"
else
  fail "Private keys detected (CRITICAL):"
  echo "$PRIV_KEYS"
fi

# ── 7. Email Addresses ──────────────────────────────────────────────────────
echo ""
echo "[ 7/10 ] Scanning for personal email addresses..."
PERSONAL_EMAILS=$(grep -rn --include="*.sh" --include="*.py" --include="*.js" --include="*.yaml" \
  --include="*.yml" --include="*.json" --include="*.md" --include="*.env" \
  --exclude-dir=".git" --exclude-dir="node_modules" \
  -E "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" \
  . 2>/dev/null | grep -v "example.com\|test.com\|placeholder\|noreply\|github.com\|users.noreply\|example@" || true)

if [ -z "$PERSONAL_EMAILS" ]; then
  pass "No personal email addresses found"
else
  warn "Potential personal email addresses detected (MEDIUM):"
  echo "$PERSONAL_EMAILS" | head -10
fi

# ── 8. IP Addresses ─────────────────────────────────────────────────────────
echo ""
echo "[ 8/10 ] Scanning for IP addresses..."
IP_ADDRS=$(grep -rn --include="*.sh" --include="*.py" --include="*.js" --include="*.yaml" \
  --include="*.yml" --include="*.json" --include="*.md" --include="*.env" \
  --exclude-dir=".git" --exclude-dir="node_modules" \
  -E "([0-9]{1,3}\.){3}[0-9]{1,3}" \
  . 2>/dev/null | grep -v "127.0.0.1\|0.0.0.0\|255.255.255.255\|example\|localhost" || true)

if [ -z "$IP_ADDRS" ]; then
  pass "No suspicious IP addresses found"
else
  warn "IP addresses detected (MEDIUM):"
  echo "$IP_ADDRS" | head -10
fi

# ── 9. OAuth Tokens ────────────────────────────────────────────────────────
echo ""
echo "[ 9/10 ] Scanning for OAuth tokens..."
OAUTH=$(grep -rn --include="*.sh" --include="*.py" --include="*.js" --include="*.yaml" \
  --include="*.yml" --include="*.json" --include="*.env" \
  --exclude-dir=".git" --exclude-dir="node_modules" \
  -E "oauth_token[[:space:]]*=[[:space:]]*['\"][^'\"]+['\"]|bearer[[:space:]]+[a-zA-Z0-9_-]+" \
  . 2>/dev/null | grep -v "privacy-check.sh\|repo-audit.sh\|workflow.md\|SKILL.md\|validate.yml\|example\|placeholder\|YOUR_" || true)

if [ -z "$OAUTH" ]; then
  pass "No OAuth tokens found"
else
  fail "OAuth tokens detected (CRITICAL):"
  echo "$OAUTH"
fi

# ── 10. Credit Card Numbers ────────────────────────────────────────────────
echo ""
echo "[ 10/10 ] Scanning for credit card patterns..."
CC_NUMS=$(grep -rn --include="*.sh" --include="*.py" --include="*.js" --include="*.yaml" \
  --include="*.yml" --include="*.json" --include="*.env" --include="*.txt" \
  --exclude-dir=".git" --exclude-dir="node_modules" \
  -E "[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}|[0-9]{16}" \
  . 2>/dev/null | grep -v "example\|test\|sample\|xxxx" || true)

if [ -z "$CC_NUMS" ]; then
  pass "No credit card patterns found"
else
  fail "Credit card patterns detected (CRITICAL):"
  echo "$CC_NUMS"
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "================================================"
echo " Privacy Scan Summary"
echo "================================================"
echo -e " ${GREEN}PASS${NC}: $PASS"
echo -e " ${YELLOW}WARN${NC}: $WARN"
echo -e " ${RED}FAIL${NC}: $FAIL"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}CRITICAL: $FAIL privacy issue(s) must be fixed before committing.${NC}"
  echo ""
  echo "=== Emergency Protocol ==="
  echo "1. If any secret was committed to a PUBLIC repo, ROTATE IMMEDIATELY"
  echo "2. Replace with placeholders: YOUR_SECRET_HERE or <REDACTED>"
  echo "3. Update .gitignore: add *.env, .env.*, secrets.*, *_secret.*"
  echo "4. Re-scan after fixes"
  echo ""
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo -e "${YELLOW}WARNING: $WARN potential privacy issue(s) found.${NC}"
  echo "Review and verify these are not sensitive before committing."
  exit 0
else
  echo -e "${GREEN}All privacy checks passed. Safe to commit.${NC}"
  exit 0
fi