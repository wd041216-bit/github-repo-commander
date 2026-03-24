# Compatibility

`github-repo-commander` is written as a public repository stewardship skill rather than a single-platform private prompt pack.

## Design goal

The public-facing instructions should remain useful across multiple agent ecosystems:

- skill-driven agent runtimes
- repository-maintenance workflows that can read `SKILL.md`
- public community collections that prefer general, portable instructions

## Stable surfaces

- [SKILL.md](../SKILL.md): primary instruction surface
- [skill.json](../skill.json): lightweight ecosystem metadata
- [_meta.json](../_meta.json): package-style metadata snapshot
- [agents/openai.yaml](../agents/openai.yaml): UI-facing skill card metadata
- [scripts/repo_commander_audit.py](../scripts/repo_commander_audit.py): deterministic helper script

## Portability rules

1. Keep the public README community-first, not tied to one runtime.
2. Keep repository examples understandable without OpenClaw-specific context.
3. Prefer generic repository stewardship language over model-brand language.
4. Treat ecosystem metadata as adapters around one core skill, not separate products.
