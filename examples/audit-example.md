# Audit Example

Example command:

```bash
python3 ./scripts/repo_commander_audit.py /path/to/repo
```

Example findings:

```text
HIGH   Potential github_token exposed in README.md
HIGH   Local machine path found in docs/setup.md
MEDIUM SKILL.md is missing YAML frontmatter
LOW    README.md does not clearly link to a Chinese README or mention localization
LOW    CONTRIBUTING.md is missing
LOW    SECURITY.md is missing
LOW    No examples/ directory found
```

Typical follow-up plan:

1. Remove or rotate secrets.
2. Replace machine-specific paths with generic placeholders.
3. Fix metadata surfaces such as `SKILL.md`, `skill.json`, and `_meta.json`.
4. Rewrite the first screen so the repo explains audience, value, and quick start clearly.
5. Add contribution, security, and example files before public submission.

