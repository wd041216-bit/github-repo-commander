# GitHub Repo Commander

Audit, polish, and package a repository before you open-source it, share it, or submit it to community directories.

For Chinese docs, see [README.zh-CN.md](./README.zh-CN.md).  
For the skill definition, see [SKILL.md](./SKILL.md).

`github-repo-commander` is a general-purpose repository stewardship skill. It combines public-facing README polish, privacy and metadata checks, and deeper GitHub workflow guidance so a repo becomes safer to publish and easier to recommend.

## Who it is for

- maintainers preparing a repo for public release
- skill or tool authors improving README, metadata, and discoverability
- people cleaning privacy leaks, weak packaging, and stale docs in one pass
- community contributors preparing repos for awesome lists or curated directories

## What it helps you do

- catch privacy and open-source blockers before publishing
- improve README first screen and project positioning
- align metadata across `README`, `SKILL.md`, `skill.json`, and package manifests
- strengthen trust signals such as changelogs, security policy, and contribution guidance
- prepare a repo for community submission or directory review

## Installation

Clone the repo into your skills directory, or attach [SKILL.md](./SKILL.md) directly in ecosystems that support file-based skills.

```bash
git clone https://github.com/wd041216-bit/openclaw-github-repo-commander.git \
  ~/.codex/skills/github-repo-commander
```

Recommended prerequisites:

- `gh`
- `git`
- Python 3 for the audit helper

## Quick example

```bash
python3 ./scripts/repo_commander_audit.py /path/to/repo
```

Typical findings:

```text
HIGH   Potential github_token exposed in README.md
HIGH   Local machine path found in docs/setup.md
MEDIUM README.md is missing a clear public-facing first screen
LOW    CHANGELOG.md is missing for a public package-style repo
LOW    No SECURITY.md found for a repo that advertises security checks
```

See [examples/audit-example.md](./examples/audit-example.md) for a fuller sample.

## Typical workflow

1. Audit the repo for privacy, packaging, and metadata gaps.
2. Fix critical blockers first:
   - tokens
   - local paths
   - personal data
   - misleading public docs
3. Improve the first screen:
   - headline
   - audience
   - quick start
   - examples
4. Align packaging and trust signals:
   - description
   - topics
   - changelog
   - contributing docs
   - security policy
5. Prepare for community submission:
   - awesome-list entry
   - alphabetical placement
   - metadata consistency

## Why this is different

Most repo tools focus on one slice of the problem: secret scanning, README generation, or discoverability. `github-repo-commander` treats GitHub readiness as one workflow:

1. make it safe
2. make it clear
3. make it credible
4. make it discoverable

That makes it a better fit for real repository cleanup, where presentation, policy, and metadata usually need to move together.

## Advanced workflow assets

This repo still includes deeper workflow material for heavier GitHub operations:

- [references/workflow.md](./references/workflow.md): extended workflow guide
- [references/gh-commands.md](./references/gh-commands.md): GitHub CLI reference
- [scripts/repo-audit.sh](./scripts/repo-audit.sh): legacy shell audit helper
- [scripts/privacy-check.sh](./scripts/privacy-check.sh): privacy-focused checks
- [scripts/competitor-search.sh](./scripts/competitor-search.sh): competitor repo search helper

## Community use

This repo is intentionally packaged as a public community skill:

- use [SKILL.md](./SKILL.md) as the main instruction surface
- use [skill.json](./skill.json) and [_meta.json](./_meta.json) for ecosystem metadata
- use [agents/openai.yaml](./agents/openai.yaml) for skill-card metadata
- use [scripts/repo_commander_audit.py](./scripts/repo_commander_audit.py) when you want a deterministic repo audit helper

## Repository contents

- [SKILL.md](./SKILL.md): main skill instructions
- [README.zh-CN.md](./README.zh-CN.md): Chinese overview
- [examples/audit-example.md](./examples/audit-example.md): sample audit findings
- [docs/compatibility.md](./docs/compatibility.md): compatibility and portability notes
- [CONTRIBUTING.md](./CONTRIBUTING.md): contribution workflow
- [SECURITY.md](./SECURITY.md): vulnerability reporting policy
- [CHANGELOG.md](./CHANGELOG.md): notable upgrades
- [scripts/repo_commander_audit.py](./scripts/repo_commander_audit.py): repo audit helper

## License

MIT
