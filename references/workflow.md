# 7-Stage Super Workflow — Detailed Reference

This document provides in-depth guidance for each stage of the Super Workflow. Load this file when you need detailed instructions beyond what is in `SKILL.md`.

## Table of Contents

1. [Stage 1: Intake](#stage-1-intake)
2. [Stage 2: Execution](#stage-2-execution)
3. [Stage 3: Reflection](#stage-3-reflection)
4. [Stage 4: Competitor Analysis](#stage-4-competitor-analysis)
5. [Stage 5: Synthesis](#stage-5-synthesis)
6. [Stage 6: Iteration](#stage-6-iteration)
7. [Stage 7: Validation](#stage-7-validation)
8. [Edge Cases](#edge-cases)
9. [Decision Trees](#decision-trees)

---

## Stage 1: Intake

**Goal:** Fully understand the request before touching any code.

### Steps

1. **Parse the request type.** Classify into one of:
   - `audit` — Review and clean up an existing repo
   - `create` — Build a new repository from scratch
   - `pr-review` — Review or create a pull request
   - `refactor` — Restructure code or documentation
   - `competitor-analysis` — Benchmark against similar projects

2. **Inspect the target repository:**
   ```bash
   gh repo view <owner>/<repo>
   gh repo view <owner>/<repo> --json name,description,stargazerCount,language,updatedAt
   ```

3. **Define success criteria.** Write them down explicitly before proceeding. Examples:
   - "All duplicate files removed, confirmed with `diff -r`"
   - "No hardcoded secrets remain (verified with `grep -r`)"
   - "README accurately lists all existing skills"
   - "CI passes on the final commit"

4. **Identify constraints.** Ask the user if unclear:
   - Is this a public or private repo?
   - Should changes go directly to `main` or via a PR?
   - Are there any files that must NOT be modified?

### Output

A written summary of: request type, target repo, success criteria, and constraints.

---

## Stage 2: Execution

**Goal:** Perform the primary GitHub operation efficiently.

### Clone and Setup

```bash
# Clone with token (if needed)
export GH_TOKEN=<your-pat>  # recommended: use env var, never embed in URL
gh repo clone <owner>/<repo>    # or: git clone https://github.com/<owner>/<repo>.git
cd <repo>

# Configure git identity
git config user.name "Your Name"
git config user.email "you@example.com"

# Create a working branch (for PR-based workflows)
git checkout -b feat/super-workflow-optimization
```

### Common Execution Patterns

**For audits:**
```bash
# Find all SKILL.md files
find . -name "SKILL.md" | sort

# Check for duplicate directories
find . -type d | sort | uniq -d

# Check for hardcoded secrets
grep -r "secret\|password\|token\|api_key" --include="*.py" --include="*.js" --include="*.md" .

# Find empty directories
find . -type d -empty
```

**For refactors:**
```bash
# Check what changed
git diff --stat HEAD~1

# Stage selectively
git add -p
```

**For PR creation:**
```bash
gh pr create \
  --title "feat: super workflow optimization v3.0" \
  --body "## Summary
  
  Applied 7-stage super workflow optimization.
  
  ## Changes
  - Removed N duplicate files
  - Fixed M documentation inconsistencies
  - Added .gitignore rules
  
  ## Testing
  - Verified with grep/diff
  - No CI failures" \
  --base main
```

---

## Stage 3: Reflection

**Goal:** Find everything that could go wrong before it does.

This is the most critical stage. Do not skip it for any structural change.

### Security Audit

```bash
# Check for hardcoded credentials
grep -rn "APP_SECRET\|APP_ID\|api_key\|password\|token" . \
  --include="*.py" --include="*.js" --include="*.ts" \
  --include="*.md" --include="*.yaml" --include="*.json" \
  --exclude-dir=".git" --exclude-dir="node_modules"

# Check for .env files accidentally committed
git log --all --full-history -- "**/.env"

# Check file permissions on scripts
find . -name "*.sh" -not -perm /111
```

### Structure Audit

```bash
# Find duplicate directories (compare content)
for dir in $(find . -type d -not -path "./.git/*" | sort); do
  echo "=== $dir ===" && ls "$dir" 2>/dev/null
done

# Find empty directories
find . -type d -empty -not -path "./.git/*"

# Check .gitignore coverage
cat .gitignore 2>/dev/null || echo "WARNING: No .gitignore found"

# Find large files (>1MB)
find . -size +1M -not -path "./.git/*" | sort -k5 -rn
```

### Documentation Audit

```bash
# Check for broken internal links in README
grep -o '\[.*\]([^)]*\.md)' README.md | grep -v "http"

# Verify all referenced files exist
grep -o '`[^`]*\.(md|py|sh|js)`' SKILL.md | tr -d '`' | while read f; do
  [ -f "$f" ] || echo "MISSING: $f"
done
```

### Reflection Questions

Answer each before proceeding to Stage 4:

1. Are there any hardcoded secrets? → If yes, remove them immediately.
2. Are there duplicate files/directories? → If yes, plan to remove them.
3. Does the README match reality? → If no, plan to update it.
4. Is `.gitignore` comprehensive? → If no, add missing rules.
5. Are there empty directories? → If yes, remove or populate them.
6. Are all scripts executable and generic? → If no, fix them.

---

## Stage 4: Competitor Analysis

**Goal:** Identify the gap between current state and industry best practices.

### Finding Competitors

```bash
# Search by topic
gh search repos github-automation --sort stars --limit 10

# Search by language + topic
gh search repos "github cli automation" --language python --sort stars --limit 10

# View a competitor's structure
gh repo clone <competitor>/<repo> /tmp/competitor-ref --depth 1
find /tmp/competitor-ref -maxdepth 3 -not -path "*/.git/*" | sort
```

### Evaluation Framework

For each top competitor, assess:

| Dimension | What to Look For |
|-----------|-----------------|
| Directory structure | Logical grouping, clear naming, no deep nesting |
| CI/CD | GitHub Actions workflows, test automation |
| Documentation | README quality, inline comments, CHANGELOG |
| `.gitignore` | Comprehensive coverage of build artifacts |
| Test coverage | Unit tests, integration tests, coverage reports |
| Security | No hardcoded secrets, dependency scanning |
| Versioning | Semantic versioning, release notes |

### Recording Findings

Create a comparison table:

```
| Feature | Our Repo | Competitor A | Competitor B |
|---------|----------|--------------|--------------|
| CI/CD   | ❌ None  | ✅ Actions   | ✅ Actions   |
| Tests   | ❌ None  | ✅ pytest    | ⚠️ Partial  |
| Docs    | ⚠️ Basic | ✅ Full      | ✅ Full      |
```

---

## Stage 5: Synthesis

**Goal:** Produce a prioritized, actionable improvement plan.

### Synthesis Template

```
## Improvement Plan

### P0 — Must Fix (blocks correctness or security)
1. [Issue from Stage 3] → [Specific fix]
2. ...

### P1 — Should Fix (improves quality significantly)
1. [Gap from Stage 4] → [Specific improvement]
2. ...

### P2 — Nice to Have (polish)
1. ...
```

### Prioritization Rules

- **P0:** Security vulnerabilities, broken functionality, data loss risk
- **P1:** Documentation gaps, duplicate code, missing `.gitignore` rules
- **P2:** Style improvements, additional examples, optional features

Present the plan to the user and get confirmation before proceeding to Stage 6.

---

## Stage 6: Iteration

**Goal:** Apply all improvements from the synthesis plan.

### Commit Strategy

Use conventional commits for clarity:

```bash
git commit -m "fix: remove hardcoded APP_SECRET from feishu scripts"
git commit -m "chore: remove duplicate ironclaw-guardian-evolved directory"
git commit -m "docs: update README to reflect actual skill count (28 not 33)"
git commit -m "chore: add comprehensive .gitignore rules"
git commit -m "feat: add monitoring/README.md with skill comparison table"
```

### Large Change Protocol

For changes affecting >10 files:

1. Group changes into logical commits (security, structure, docs)
2. Show the user a `git diff --stat` before committing
3. Get explicit confirmation: "These N files will be changed. Proceed?"
4. Commit in batches with clear messages

### Rollback Plan

```bash
# If something goes wrong
git log --oneline -10  # Find the last good commit
git revert HEAD        # Revert last commit safely
# OR
git reset --soft HEAD~1  # Undo last commit, keep changes staged
```

---

## Stage 7: Validation

**Goal:** Confirm all changes are correct and deliver results to the user.

### Pre-Push Checklist

```bash
# Final security scan
grep -rn "secret\|password\|token" . --include="*.py" --include="*.md" \
  --exclude-dir=".git" --exclude-dir="node_modules"

# Verify .gitignore is working
git status --short | grep "node_modules\|__pycache__" && echo "WARNING: ignored files staged"

# Check commit history
git log --oneline -5

# Dry run push
git push --dry-run origin main
```

### Push and Verify

```bash
# Push changes
git push origin main

# Verify on GitHub
gh repo view <owner>/<repo>

# Check CI status (if applicable)
gh run list --limit 3
gh run view <latest-run-id>
```

### Delivery Report

Always provide the user with:

1. **GitHub link** to the updated repository
2. **Summary table** of all changes made
3. **Key insights** from Stage 3 (what was found) and Stage 4 (what competitors do better)
4. **Next steps** (optional improvements not yet implemented)

---

## Edge Cases

### Authentication Failures

```bash
# Check current auth status
gh auth status

# Re-authenticate
gh auth logout
gh auth login --web

# Use PAT directly
export GH_TOKEN=<your-token>
gh auth status
```

### Large Repositories (>500MB)

```bash
# Shallow clone to save time
git clone --depth 1 https://github.com/<owner>/<repo>.git

# Or clone only specific branch
git clone --single-branch --branch main https://github.com/<owner>/<repo>.git
```

### Protected Branches

When `main` is protected and direct push is blocked:

```bash
# Create a feature branch
git checkout -b fix/super-workflow-cleanup

# Push the branch
git push origin fix/super-workflow-cleanup

# Create PR
gh pr create --title "chore: super workflow cleanup" --base main
```

### Rate Limiting

```bash
# Check rate limit status
gh api rate_limit

# If limited, wait or use a different token
export GH_TOKEN=<alternate-token>
```

---

## Decision Trees

### Should I use a PR or push directly to main?

```
Is the repo owned by you or your org?
├── Yes → Is main branch protected?
│   ├── Yes → Use PR
│   └── No → Push directly (confirm with user first for large changes)
└── No → Always use PR (fork + PR)
```

### Should I run Stage 4 (Competitor Analysis)?

```
Is this task structural? (new feature, refactor, new repo)
├── Yes → Always run Stage 4
└── No (bug fix, typo, minor update)
    └── Skip Stage 4, proceed to Stage 5 with only Stage 3 findings
```
