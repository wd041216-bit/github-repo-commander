# Changelog

## 2026-03-24

- Repositioned the repo as a broader community skill for Codex, OpenClaw, and similar agent runtimes.
- Rewrote `README.md` and `README.zh-CN.md` around public-facing outcomes, audience, installation, and workflow.
- Added `CONTRIBUTING.md`, `SECURITY.md`, compatibility notes, and example audit output.
- Added GitHub issue templates and a pull request template.
- Expanded the Python audit helper to flag missing contribution, security, and example surfaces for public repos.

## [4.2.0] - 2026-03-19

### Added

- **Stage 3.5: Privacy Information Cleanup** — New critical stage for detecting and removing sensitive information
- `scripts/privacy-check.sh` — Standalone privacy scan script with 10 comprehensive checks
- **Enhanced `repo-audit.sh`** — Added `--privacy` flag for enhanced privacy scanning

### Changed

- **SKILL.md** — Added comprehensive privacy cleanup guidance
- **`repo-audit.sh`** — Enhanced secret pattern detection

## [4.0.0] - 2026-03-18

### Added

- `.github` templates and CI validation
- `CONTRIBUTING.md`
- `references/workflow.md`
- `references/gh-commands.md`
- `scripts/repo-audit.sh`
- `scripts/competitor-search.sh`

