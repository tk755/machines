---
description: Sync local changes to the remote repository
allowed-tools: Bash, Read, Grep, Glob
---

## Steps

### 1. Check status

Run these commands in parallel:
- `git status` to see changed and staged files
- `git diff` to see unstaged changes
- `git diff --cached` to see staged changes
- `git log --author="$(git config user.email)" --oneline -15` to see recent commit style

### 2. Analyze changes

Review the diff output to understand what changed and why. Group related changes into logical commits — prefer one commit when all changes share a theme, split only when changes are clearly unrelated.

### 3. Handle untracked files

If the user mentions files they want to add that aren't already tracked, **always ask for confirmation** before staging them. Never add untracked files without explicit approval.

When adding new files, check for supporting files that logically belong together (e.g., a skill's templates, examples, or scripts; a config's associated directories or includes). Propose adding these as part of the same commit.

### 4. Propose commits

For each logical group of changes, propose:
- Which files to stage
- A **single-line** commit message matching the repo's style (lowercase, no bullet points, no multi-line bodies)

Present the plan and wait for user approval. If the user requests any changes, update the plan accordingly and present the revised plan iteratively until they approve. Never proceed to commit until the user explicitly approves the final plan.

### 5. Commit

After approval, stage and commit using:
```
git add <files>
git commit -m '<message>'
```

**NEVER ADD YOURSELF AS A CO-AUTHOR** — the repo's history should reflect the original author of each change, not the assistant who helped write the commit message. Do not include `Co-authored-by` lines or any attribution to yourself in commits.

### 6. Push

After committing, ask the user if they want to push. Push with:
```
git push
```
