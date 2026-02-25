---
description: Sync local changes to a repository
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob
---

## Instructions

### 1. Fetch changes

Run these commands in parallel:
- `git status` to see changed and staged files
- `git diff` to see unstaged changes
- `git diff --cached` to see staged changes
- `git log --author="$(git config user.email)" --oneline -15` to see recent commit style

### 2. Analyze changes

Review the diff output to understand what changed and why. Group related changes into logical commits — prefer one commit when all changes share a theme, split only when changes are clearly unrelated.

### 3. Handle untracked files

If the user mentions files they want to add that aren't already tracked, check for supporting files needed for completeness (configs, libraries, scripts) and propose them together. Always ask for confirmation before staging untracked files.

### 4. Propose commits

For each logical group of changes, propose:
- Which files to stage
- A **single-line** commit message (lowercase, no bullet points, no multi-line bodies)

Present the plan and wait for explicit approval before committing. Do not proceed to commit until the user approves both the files and the message.

### 5. Commit

After approval, stage and commit using:
```
git add <files>
git commit -m '<message>'
```

Never add `Co-authored-by` lines or any self-attribution to commits.

### 6. Push

After committing, ask the user if they want to push. Push with:
```
git push
```

If the push fails because the remote has diverged, stop and ask the user how they want to resolve it. Never force push without explicit approval.
