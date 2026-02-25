---
description: Sync local dotfile changes to the dotfiles repository
allowed-tools: Bash, Read, Grep, Glob, Skill
---

## Dotfiles repo context

The dotfiles repo is a bare git repo at `$HOME/.dotfiles` with `$HOME` as the worktree. All git commands must be prefixed with:
```
git --git-dir=$HOME/.dotfiles --work-tree=$HOME
```

For example, `git status` becomes `git --git-dir=$HOME/.dotfiles --work-tree=$HOME status`.

The repo has `status.showUntrackedFiles` set to `no`, so new files won't appear in status. Use the conversation context to identify new files that should be added, and **always ask for confirmation** before staging them.

Commit message style for this repo:
- **Lowercase** — no capitalization
- **Concise** — short phrase, not a sentence
- **No period** — no trailing punctuation
- **Descriptive** — says what changed, not why
- Examples: `update ruff rule list`, `add claude commit skill`, `add file extensions to non-PATH scripts`

## Execution

Apply the context above, then invoke the `/commit` skill.
