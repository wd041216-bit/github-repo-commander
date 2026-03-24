---
name: github-repo-commander
homepage: https://github.com/wd041216-bit/openclaw-github-repo-commander
description: Audit, polish, and package GitHub repositories before open-sourcing, sharing, or community submission, with privacy checks, README upgrades, metadata alignment, and discoverability improvements.
---

# GitHub Repo Commander

Use this skill when a GitHub repository should be improved as a whole, not just in one narrow dimension.

## What this skill is for

Use it when the user wants to:

- audit a repo before open-sourcing
- make a repo cleaner and more presentable on GitHub
- improve README, visual hierarchy, and project packaging
- improve discoverability and recommendation readiness
- remove model-specific assumptions from prompts or scripts
- prepare a repo or skill for submission to an awesome-list
- generalize a personal ecosystem-specific skill into a broader community skill

## Commanding workflow

1. Inspect the repo with `gh` when the remote exists.
2. Run the privacy/compliance audit script.
3. Fix critical open-source blockers first:
   - tokens
   - `.env`
   - local machine paths
   - accidental personal data
4. Then improve packaging and discoverability:
   - repo description
   - README first screen
   - bilingual README coverage when relevant
   - screenshots / demo / topics
   - trust-signal files
5. If the repo changed in a user-visible way, update the public docs at the same time:
   - `README.md`
   - `README.zh-CN.md` when the repo uses a Chinese doc track
   - `CHANGELOG.md` or release notes for meaningful upgrades
6. If the repo is skill-like, verify:
   - `SKILL.md` frontmatter
   - `skill.json`
   - `_meta.json`
7. If the target is an awesome-list or public skill ecosystem:
   - normalize repository URL
   - verify ordering and category fit
   - reduce ecosystem-specific jargon in the public README
   - include at least one concrete example or sample output

## Built-in audit script

Run:

```bash
python3 ./scripts/repo_commander_audit.py /path/to/repo
```

Useful flags:

```bash
python3 ./scripts/repo_commander_audit.py /path/to/repo --json
python3 ./scripts/repo_commander_audit.py /path/to/repo --strict
```

The script checks for:

- `.env`, secrets, token-like strings
- leaked local paths with personal usernames or machine-specific home directories
- missing skill metadata files
- obviously model-specific wording
- README presence and packaging issues
- bilingual README coverage and cross-link expectations
- changelog / upgrade-note presence for public package-style repos
- missing contribution and security policy surfaces for public-facing repos

## Advanced supporting files

This repo also contains deeper workflow assets for heavier GitHub operations:

- `references/workflow.md`
- `references/gh-commands.md`
- `scripts/repo-audit.sh`
- `scripts/privacy-check.sh`
- `scripts/competitor-search.sh`

## Commander rules

- Fix safety and privacy problems before beautifying the repo
- Once safety is acceptable, actively improve the repo's presentation instead of stopping at compliance
- If the upgrade changes visible behavior, update the docs in the same pass instead of treating docs as optional follow-up
- Prefer human-readable GitHub positioning over keyword stuffing
- Keep PR fixes focused and easy to review
- Prefer general community framing in the public README even when the repo also supports one specific ecosystem

## Output expectations

When you use this skill well, the result should usually include:

- critical findings first
- a proposed remediation plan
- concrete README / metadata / discoverability changes
- any contribution / security / example files needed for public trust
- if relevant, a PR-ready awesome-list entry or ordering note
