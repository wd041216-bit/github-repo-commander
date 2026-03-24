# Contributing

Thanks for improving `github-repo-commander`.

## Good contributions

- clearer public positioning for community users
- better repository audit coverage
- stronger examples or before/after docs
- metadata consistency improvements
- fixes that make the skill more model-agnostic and ecosystem-neutral

## Before you open a PR

1. Keep the public README community-friendly, not ecosystem-exclusive.
2. Update both [README.md](./README.md) and [README.zh-CN.md](./README.zh-CN.md) when the public-facing behavior changes.
3. Update [CHANGELOG.md](./CHANGELOG.md) for notable user-visible upgrades.
4. If you change audit behavior, include or update an example in [examples/audit-example.md](./examples/audit-example.md).

## Local validation

Run the audit helper against this repo or a sample repo:

```bash
python3 ./scripts/repo_commander_audit.py .
```

Useful variants:

```bash
python3 ./scripts/repo_commander_audit.py . --json
python3 ./scripts/repo_commander_audit.py . --strict
```

## Commit style

Prefer concise conventional commit prefixes:

- `feat:`
- `fix:`
- `docs:`
- `refactor:`
- `chore:`

## Pull request expectations

- keep changes focused
- explain user-visible impact briefly
- avoid reverting unrelated local edits
- prefer examples over abstract claims
