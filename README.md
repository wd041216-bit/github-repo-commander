# openclaw-github-repo-commander

> An AI-powered GitHub repository management skill that applies the **7-Stage Super Workflow** to every task — deep audit, competitor benchmarking, and iterative optimization.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-compatible-blue)](https://agentskills.io)
[![Version](https://img.shields.io/badge/version-3.0.0-green)](CHANGELOG.md)

---

## What It Does

This skill transforms any AI agent into a senior open-source maintainer. When activated, it applies a structured 7-stage process to GitHub tasks: understanding the request, executing the operation, critically reflecting on the result, benchmarking against top competitors, synthesizing improvements, iterating, and validating the final output.

The skill is designed to prevent the most common failure modes in automated repository management: hardcoded secrets, duplicate files, stale documentation, missing `.gitignore` rules, and shallow analysis that misses structural problems.

---

## Installation

**Via Manus Skills (recommended):**

Attach the `SKILL.md` file to your Manus agent, or clone the full repository for access to all scripts and references.

**Manual installation:**

```bash
git clone https://github.com/wd041216-bit/openclaw-github-repo-commander.git \
  ~/.claude/skills/openclaw-github-repo-commander
```

**Prerequisites:** `gh` (GitHub CLI >= 2.40) and `git` (>= 2.30). Run `gh auth login` once before first use.

---

## Usage

Simply mention a GitHub task in your conversation. The skill activates automatically for:

| Trigger Phrase | What Happens |
|----------------|--------------|
| "Manage my GitHub repo" | Full 7-stage repo audit and optimization |
| "Clean up this library" | Removes duplicates, fixes docs, adds .gitignore |
| "Review this PR" | Security + quality PR review with competitor context |
| "Create a new project" | Creates repo and benchmarks against top competitors |
| "Use super workflow on my code" | Full 7-stage optimization cycle |
| "Analyze competitor repos" | Structured competitor benchmarking report |
| `/super-workflow <repo-url>` | Runs the complete workflow on any repository |

---

## The 7-Stage Super Workflow

The skill applies this process to every non-trivial task:

**Stage 1 — Intake:** Parse the request type, inspect the target repository with `gh repo view`, and define explicit success criteria before touching any code.

**Stage 2 — Execution:** Perform the primary GitHub operation (clone, edit files, create PR, etc.) using the appropriate `gh` and `git` commands.

**Stage 3 — Reflection:** Run the automated audit script (`scripts/repo-audit.sh`) and manually verify: no hardcoded secrets, no duplicate directories, no empty stubs, comprehensive `.gitignore`, and accurate documentation.

**Stage 4 — Competitor Analysis:** Search top-starred repositories in the same domain (`gh search repos <keyword> --sort stars`), inspect their structure, and identify gaps between the current state and industry best practices.

**Stage 5 — Synthesis:** Combine Stage 3 and Stage 4 findings into a prioritized improvement plan (P0/P1/P2), presented to the user for confirmation before execution.

**Stage 6 — Iteration:** Apply all approved improvements with descriptive conventional commits. For large changes (>10 files), show a `git diff --stat` and get explicit user confirmation.

**Stage 7 — Validation:** Push changes, verify CI/CD status with `gh run list`, and deliver a summary report with the GitHub link, change table, and key insights.

---

## Repository Structure

```
openclaw-github-repo-commander/
├── SKILL.md                    # Skill metadata + concise instructions
├── README.md                   # This file
├── CHANGELOG.md                # Version history
├── LICENSE                     # MIT License
├── .gitignore                  # Standard exclusions
├── references/
│   ├── workflow.md             # 7-stage workflow detailed guide
│   └── gh-commands.md          # Complete gh CLI command reference (50+)
└── scripts/
    ├── repo-audit.sh           # Automated Stage 3 audit (7 checks)
    └── competitor-search.sh    # Stage 4 competitor search helper
```

---

## Automated Audit Script

The `scripts/repo-audit.sh` script automates Stage 3 checks:

```bash
# Audit the current directory
./scripts/repo-audit.sh

# Audit a specific repository
./scripts/repo-audit.sh /path/to/repo
```

The script runs 7 checks: hardcoded secrets scan, `.gitignore` coverage, empty directory detection, large file detection, `node_modules` tracking, broken README links, and script executability. It exits with code 1 if any critical issues are found.

---

## Real-World Example

```
User: "Audit and optimize wd041216-bit/openclaw-ultimate-suite"

Stage 1: Clones repo, identifies 44 skills, notes 3.8MB node_modules committed
Stage 2: Runs git log, scans for duplicates and secrets
Stage 3: Finds APP_SECRET hardcoded in feishu scripts, 3 empty dirs, 2 duplicate skill dirs
Stage 4: Searches "agent skills" on GitHub, finds anthropics/skills (95.8k stars)
Stage 5: Plan: remove duplicates, fix secrets, add .gitignore, update README
Stage 6: Executes cleanup with 3 commits; removes 62,072 lines of redundant content
Stage 7: Pushes, shows diff stats, delivers GitHub link with full change summary
```

---

## FAQ

**Q: The skill did not activate automatically. What should I do?**

Mention the task more explicitly, for example: "Use the GitHub Repo Commander skill to audit my repo at `<url>`." If the skill is installed correctly, this will always trigger it.

**Q: `gh auth status` shows my token is expired.**

Run `gh auth logout && gh auth login` to re-authenticate. If using a Personal Access Token, set `export GH_TOKEN=<your-new-token>`.

**Q: The audit script found hardcoded secrets. What now?**

Remove the secrets from the file immediately. Then run `git log --all --full-history -- <file>` to check if they were ever committed. If so, you must rotate the credentials in the affected service — removing from the current commit is not sufficient if the secret exists in git history.

**Q: Can I use this skill on private repositories?**

Yes. The skill uses `gh` CLI which respects your GitHub authentication. Ensure your token has the `repo` scope for private repository access.

**Q: Can I skip the competitor analysis step for small tasks?**

For minor tasks (typo fixes, small updates), Stage 4 can be skipped. For structural changes (new features, refactors, new repositories), Stage 4 is mandatory — it consistently surfaces improvements that would otherwise be missed.

---

## Related Skills

- [openclaw-ultimate-suite](https://github.com/wd041216-bit/openclaw-ultimate-suite) — The full skill suite that includes this skill alongside 27 others

---

## Contributing

Contributions are welcome. Please open an issue first to discuss proposed changes, then submit a pull request. See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## License

MIT — see [LICENSE](LICENSE) for details.
