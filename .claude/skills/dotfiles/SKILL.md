---
description: Sync local dotfile changes to the dotfiles repository
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob, Skill
---

## Context

Bare git repo at `$HOME/.dotfiles` with `$HOME` as the worktree. All git commands must be prefixed with:
```
git --git-dir=$HOME/.dotfiles --work-tree=$HOME
```

`status.showUntrackedFiles` is set to `no` so new files won't appear in status. Use conversation context to identify new files to add, and always ask for confirmation before staging them.

Commit messages are lowercase, concise, descriptive, with no trailing punctuation (e.g. `update ruff rule list`, `add file extensions to non-PATH scripts`).

## Execution

Apply the context above, then invoke the `/commit` skill.
