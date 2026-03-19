# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.2.0] - 2026-03-19

### Added
- **Stage 3.5: Privacy Information Cleanup** — New critical stage for detecting and removing sensitive information
- `scripts/privacy-check.sh` — Standalone privacy scan script with 10 comprehensive checks
- **Enhanced `repo-audit.sh`** — Added `--privacy` flag for enhanced privacy scanning
- Privacy detection patterns: GitHub tokens, API keys, passwords, secrets, database URLs, private keys, email addresses, IP addresses, OAuth tokens, credit cards
- Emergency protocol for leaked secrets in `references/workflow.md`
- Expanded `.gitignore` patterns for privacy-sensitive files

### Changed
- **SKILL.md** — Added comprehensive Stage 3.5 section with privacy cleanup workflow
- **`repo-audit.sh`** — Enhanced secret pattern detection (now detects `ghp_`, `gho_`, `ghu_`, `ghs_`, `ghr_`, `sk-`, `sk_live_`)
- **`references/workflow.md`** — Added detailed Stage 3.5 documentation with risk levels and reflection questions

### Security
- **CRITICAL FIX** — Prevents accidental commits of sensitive tokens and credentials
- Added real-world incident documentation (GitHub token leak incident)

## [4.0.0] - 2026-03-18

### Fixed
- **Version inconsistency**: Synchronized `SKILL.md` `metadata.version` and `_meta.json` version (both now `4.0.0`)
- **Non-standard `allowed-tools` field**: Removed from SKILL.md frontmatter (not part of official Manus spec)
- **Token-in-URL anti-pattern**: `references/workflow.md` now recommends `GH_TOKEN` env var instead of embedding token in clone URL
- **Fictitious `clawdbot` install command**: README now shows correct Manus-based installation instructions

### Added
- `.github/workflows/validate.yml`: GitHub Actions CI — validates SKILL.md frontmatter, script syntax, line count, and runs `repo-audit.sh` on every push/PR
- `.github/ISSUE_TEMPLATE/bug_report.md`: Structured bug report template
- `.github/ISSUE_TEMPLATE/feature_request.md`: Structured feature request template
- `.github/pull_request_template.md`: PR checklist template
- `CONTRIBUTING.md`: Contribution guide with commit conventions and quality standards

### Changed
- `_meta.json` tags expanded: added `audit`, `cleanup`, `optimization` for better discoverability

## [3.0.0] — 2026-03-18

### Added

- `references/workflow.md` — Detailed 7-stage workflow guide with decision trees, edge cases, and per-stage checklists (replaces inline SKILL.md content)
- `references/gh-commands.md` — Complete GitHub CLI command reference (50+ commands across all categories)
- `scripts/repo-audit.sh` — Automated Stage 3 Reflection audit script (7 checks: secrets, .gitignore, empty dirs, large files, node_modules, broken links, script permissions)
- `scripts/competitor-search.sh` — Stage 4 Competitor Analysis helper script
- `allowed-tools` frontmatter field (`Bash(gh:*) Bash(git:*)`) per Agent Skills spec
- Troubleshooting section to SKILL.md

### Changed

- **SKILL.md frontmatter** now fully complies with [Agent Skills specification](https://agentskills.io/specification):
  - Removed non-standard `version` top-level field (moved to `metadata.version`)
  - Removed non-standard `homepage` top-level field (moved to `metadata.homepage`)
  - Removed non-standard `metadata.clawdbot` nested object
  - Added `compatibility` field for dependency declaration
  - Added `allowed-tools` field
- **`description` field** significantly expanded with more trigger keywords and "pushy" phrasing per Anthropic's anti-undertriggering guidance
- **SKILL.md body** restructured: detailed workflow content moved to `references/workflow.md`; SKILL.md now serves as a concise overview with links to references
- **README.md** language unified (English throughout); removed mixed Chinese/English trigger word table

### Fixed

- Reflection checklist now includes `*.orig` and binary file checks
- Competitor analysis guide now includes structure inspection commands

## [2.1.0] — 2026-03-17

### Added

- Security & Privacy section with trust statement
- Dependencies table with version requirements
- Reflection checklist (Stage 3)
- Competitor analysis guide (Stage 4)
- `homepage` field in `_meta.json` pointing to this repository

### Changed

- Extracted from `openclaw-ultimate-suite` into standalone repository
- Updated `_meta.json` homepage from suite URL to this repo's URL

## [2.0.0] — 2026-03-15

### Added

- Full 7-stage Super Workflow integration
- Complete `gh` CLI command reference table
- Trigger scenarios section (Chinese)

### Changed

- Major rewrite from basic GitHub helper to full Super Workflow skill

## [1.0.0] — 2026-03-01

### Added

- Initial release as part of `openclaw-ultimate-suite`
- Basic GitHub repository management commands
- PR creation and review workflow
