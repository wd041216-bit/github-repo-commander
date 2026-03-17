# Contributing to openclaw-github-repo-commander

Thank you for your interest in improving this skill. Contributions are welcome.

## How to Contribute

### Reporting Bugs

Open an issue using the **Bug Report** template. Include your `gh` version, OS, and the exact command that triggered the issue.

### Suggesting Features

Open an issue using the **Feature Request** template. Describe the use case clearly — the more concrete, the better.

### Submitting a Pull Request

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature-name`
3. Make your changes
4. Run the validation script: `bash scripts/repo-audit.sh .`
5. Commit with a conventional commit message (see below)
6. Push and open a PR against `main`

## Commit Message Convention

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | When to use |
|--------|-------------|
| `feat:` | New feature or capability |
| `fix:` | Bug fix |
| `docs:` | Documentation only |
| `chore:` | Maintenance (version bumps, CI, etc.) |
| `refactor:` | Code restructuring without behavior change |

**Examples:**
```
feat: add Stage 4 competitor scoring matrix to workflow.md
fix: repo-audit.sh false positive on grep exit code
docs: update README installation instructions
chore: bump version to 4.1.0
```

## Quality Standards

All PRs must pass the automated CI checks:
- SKILL.md has valid frontmatter with `name` and `description`
- SKILL.md is under 500 lines
- All `.sh` scripts pass `bash -n` syntax check
- No hardcoded secrets detected
- `scripts/repo-audit.sh` exits with 0 FAIL

## Questions

Open a GitHub Discussion or issue if you have questions.
