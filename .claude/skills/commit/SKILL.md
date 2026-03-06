---
description: Commit and push local changes to git. Use when the user asks to commit, push, or sync changes, or has finished making changes and wants to save their work.
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

Present the plan and wait for explicit approval before committing. Revision requests are not approval — words like "tighter", "reword", or a suggested message mean revise the proposal and wait again. Only proceed when the user explicitly confirms (e.g. "yes", "go ahead", "commit it").

### 5. Commit

After approval, stage and commit using:
```
git add <files>
git commit -m '<message>'
```

Never add `Co-authored-by` lines or any self-attribution to commits.

### 6. Push

Push after committing, unless the user said "just commit", "commit only", "no push", or similar. If the push fails because the remote has diverged, stop and ask the user how they want to resolve it. Never force push without explicit approval.
