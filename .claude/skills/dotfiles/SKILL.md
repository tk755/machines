---
description: Sync local dotfile changes to the dotfiles repository
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob
---

Sync local changes to the dotfiles bare repository at `~/.dotfiles`.

The dotfiles repo is a bare git repo with `$HOME` as the worktree. All git operations use:
```
git --git-dir=$HOME/.dotfiles --work-tree=$HOME
```

## Steps

### 1. Check status

Run these commands in parallel:
- `git --git-dir=$HOME/.dotfiles --work-tree=$HOME status` to see changed and staged files
- `git --git-dir=$HOME/.dotfiles --work-tree=$HOME diff` to see unstaged changes
- `git --git-dir=$HOME/.dotfiles --work-tree=$HOME diff --cached` to see staged changes
- `git --git-dir=$HOME/.dotfiles --work-tree=$HOME log --oneline -15` to see recent commit style

### 2. Analyze changes

Review the diff output to understand what changed and why. Group related changes into logical commits — prefer one commit when all changes share a theme, split only when changes are clearly unrelated.

### 3. Handle untracked files

The repo has `status.showUntrackedFiles` set to `no`, so new files won't appear in status. If the user mentions files they want to add that aren't already tracked, **always ask for confirmation** before staging them. Never add untracked files without explicit approval.

When adding new files, check for supporting files that logically belong together (e.g., a skill's templates, examples, or scripts; a config's associated directories or includes). Propose adding these as part of the same commit.

### 4. Propose commits

For each logical group of changes, propose:
- Which files to stage
- A commit message matching the repo's style

Commit message style (from repo history):
- **Lowercase** — no capitalization
- **Concise** — short phrase, not a sentence
- **No period** — no trailing punctuation
- **Descriptive** — says what changed, not why
- Examples: `update ruff rule list`, `add ruff config`, `preserve author date on rebase`, `update claude permissions`

Present the plan and wait for user approval before committing.

### 5. Commit

After approval, stage and commit using:
```
git --git-dir=$HOME/.dotfiles --work-tree=$HOME add <files>
git --git-dir=$HOME/.dotfiles --work-tree=$HOME commit -m '<message>'
```

### 6. Push

After committing, ask the user if they want to push. Push with:
```
git --git-dir=$HOME/.dotfiles --work-tree=$HOME push
```
