# skun-skills

Skills my agents carry everywhere.

One folder per skill under `skills/`, each with a `SKILL.md` (YAML frontmatter with `name` and `description`, then instructions).

```
skills/
  <skill-name>/
    SKILL.md
    ...supporting files
```

## Install

```bash
./link.sh
```

Symlinks every skill into `~/.claude/skills/`, so Claude Code picks them up in every project. Edits here are live immediately; re-run after adding a new skill.
