---
name: openclaw-github-repo-commander
description: >
  Manages GitHub repositories using a 7-stage Super Workflow: deep audit, competitor
  analysis, structural cleanup, PR review, and iterative optimization. Use this skill
  whenever the user mentions managing a repo, reviewing a PR, refactoring a codebase,
  creating a new project, analyzing competitor repos, cleaning up skills or libraries,
  running a super workflow, or any GitHub-related task that benefits from systematic
  analysis. Activate even if the user only says "optimize my repo", "clean up this
  library", "review this code", "compare with competitors", or "use super workflow" -
  this skill handles all of it.
license: MIT
compatibility: Requires gh (GitHub CLI >= 2.40) and git (>= 2.30). Run gh auth login before first use.
metadata:
  author: wd041216-bit
  version: "4.0.0"
  homepage: https://github.com/wd041216-bit/openclaw-github-repo-commander
---

# GitHub Repo Commander

An AI-powered GitHub repository management skill that applies the **7-Stage Super Workflow** to every task, ensuring each commit, PR review, or repo restructure is backed by deep reflection and competitor benchmarking.

## When to Use This Skill

Activate automatically when the user asks to:

- Manage, audit, or clean up a GitHub repository
- Review or create a pull request
- Refactor or restructure a codebase
- Create a new project (and benchmark against competitors)
- Analyze competitor repositories
- Apply a "super workflow" or "deep optimization" to any code
- Delete low-value files, skills, or dependencies from a library
- Run `/super-workflow` on a repository URL

## Quick Start

```bash
# Authenticate (one-time setup)
gh auth login

# Verify access
gh auth status

# Clone target repository
gh repo clone <owner>/<repo>
```

## 7-Stage Super Workflow

For all non-trivial tasks, execute these stages in order. See [`references/workflow.md`](references/workflow.md) for detailed per-stage guidance.

| Stage | Name | Key Action |
|-------|------|------------|
| 1 | **Intake** | Understand the request, inspect repo state, define success criteria |
| 2 | **Execution** | Perform the primary GitHub operation (clone, edit, create PR, etc.) |
| 3 | **Reflection** | Critically audit the work: security, scalability, docs, test coverage |
| 4 | **Competitor Analysis** | Search top-starred repos; identify gaps vs. best practices |
| 5 | **Synthesis** | Combine reflection + competitor findings into an actionable plan |
| 6 | **Iteration** | Apply improvements; commit with descriptive messages |
| 7 | **Validation** | Push, verify CI/CD, deliver GitHub link + summary to user |

> **Rule:** Never skip Stage 3 (Reflection) or Stage 4 (Competitor Analysis) for structural changes. Surface-level success is not acceptable.

## Core Operations

### Repository Management

```bash
gh repo view <owner>/<repo>                        # Inspect repo metadata
gh repo clone <owner>/<repo>                       # Clone locally
gh repo create <name> --private                    # Create new private repo
gh search repos <keyword> --sort stars --limit 10  # Find competitors
gh repo fork <owner>/<repo>                        # Fork a repo
```

### Pull Requests and Issues

```bash
gh pr create --title "<title>" --body "<body>"  # Create PR
gh pr list                                       # List open PRs
gh pr review <id> --comment "<feedback>"         # Review PR
gh pr merge <id> --squash                        # Merge PR
gh issue list                                    # List issues
gh issue create --title "<title>"                # Create issue
```

### CI/CD and Releases

```bash
gh run list --limit 5          # View recent workflow runs
gh run view <run-id>           # Inspect a specific run
gh release create v1.0.0       # Create a release
gh release list                # List all releases
```

For the full command reference (50+ commands), see [`references/gh-commands.md`](references/gh-commands.md).

## Reflection Checklist (Stage 3)

Before committing any structural change, verify all of the following:

- [ ] No hardcoded credentials, tokens, or secrets in any file
- [ ] No duplicate files or directories (use `diff -r` to confirm)
- [ ] No empty directories or placeholder stubs without content
- [ ] `node_modules/`, `__pycache__/`, `.env`, `*.orig` are in `.gitignore`
- [ ] README accurately reflects the current state of the repo
- [ ] All referenced files and links actually exist
- [ ] Scripts are executable and have no hardcoded business-specific values
- [ ] No large binary files committed accidentally

## Competitor Analysis Guide (Stage 4)

```bash
# Find top competitors
gh search repos <keyword> --sort stars --limit 10

# Inspect a competitor structure
gh repo clone <competitor>/<repo> /tmp/competitor-ref
find /tmp/competitor-ref -maxdepth 3 -type f | head -30
```

Evaluate competitors on: directory structure, CI/CD setup, documentation quality, test coverage, `.gitignore` completeness, and README clarity.

## Security and Privacy

| Item | Detail |
|------|--------|
| External endpoints | `api.github.com` only (via `gh` CLI) |
| Data leaving machine | Only git commit content and PR descriptions |
| Data staying local | All file contents (unless explicitly pushed) |
| Credential handling | Managed via `gh auth`; never hardcode tokens |

> **Trust Statement:** This skill interacts exclusively with `api.github.com` through the official GitHub CLI. Only install if you trust the GitHub platform with your repository data.

## Dependencies

| Tool | Min Version | Install |
|------|-------------|---------|
| `gh` | 2.40 | [cli.github.com](https://cli.github.com/) |
| `git` | 2.30 | System package manager |

Run `gh auth login` once before first use.

## Troubleshooting

**Token expired:** `gh auth logout && gh auth login`

**Push rejected (non-fast-forward):** `git pull --rebase origin main && git push`

**`gh` not found:** `brew install gh` / `sudo apt install gh` / `winget install GitHub.cli`

For advanced edge cases, see [`references/workflow.md`](references/workflow.md).
