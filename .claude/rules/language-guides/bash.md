# Bash Conventions

Codified decisions for writing and reviewing bash scripts.

## Quoting

- Prefer `"${var}"` over `"$var"` for named variables (clarity in concatenation)
- Bare `$1`, `$?`, `$_` for single-character specials and positional parameters
- Always double-quote expansions: `"${var}"`, `"${array[@]}"`, `"$(command)"`
- Single quotes for literals passed to other programs: `grep 'pattern'`, `awk '{print $1}'`
- Quote variables inside `${}` patterns separately: `"${file#"$prefix"}"` (SC2295)
- Safe to omit quotes: inside `[[ ]]` left side of `==`, inside `(( ))`

## Test Expressions

- `[[ ]]` for string and file tests (not `[ ]`)
- `(( ))` for integer comparisons (not `[ -gt ]` or `[[ -gt ]]`)
- Bare commands for exit code tests: `if ! command; then` (not `if [ $? -ne 0 ]`)
- `==` for string comparison inside `[[ ]]` (not `=`)
- Reserve `[ ]` only for POSIX sh scripts (`#!/bin/sh`)

## Arithmetic

- `(( ))` for conditions and side effects: `(( count++ ))`, `if (( n > 0 ))`
- `$(( ))` for value expansion: `total=$(( a + b ))`
- No `$` needed on variables inside `(( ))` and `$(( ))` (except `${#array[@]}` and similar)
- Never use `let`, `$[ ]`, or `expr`

## Command Substitution

- `$(command)`, never backticks

## Functions

- Declare as `name() {` (no `function` keyword)
- `local` for all variables except script-level constants
- Avoid naming variables after builtins (`exit`, `test`, etc.)

## Script Structure

- Shebang: `#!/usr/bin/env bash`
- `set -euo pipefail` in all executable scripts
- `main()` pattern: define main, call `main "$@"` at bottom
- Sourced files (`.bashrc`, `env.sh`, `aliases.sh`) skip shebang and set flags

## Sourcing

- `source` in bash scripts, `.` only in POSIX sh scripts

## Output

- Prefer `printf` over `echo -e` for formatted/colored output
- Errors to stderr: `echo "error message" >&2`

## Redirections

- No space between fd and `>`: `2>/dev/null` (not `2> /dev/null`)
- `&>/dev/null` for discarding all output
- `2>&1 |` for piping both stdout and stderr

## Loops & Pipes

- `< <(command)` with while loops, not `command | while` (subshell scope issue)
- `while IFS= read -r line` is the standard line-reading idiom

## Portability

- GNU-specific flags (`grep -P`, `find -printf`, `sed -i` without backup arg) are fine for Linux-only scripts
- Flag with a comment if the script might run on macOS

## Error Handling

- `cd dir || exit` (or `|| return`) to avoid silent failure (SC2164)
- `ls | grep` is fragile — use globs or `find` instead (SC2010)

## Avoid

- `eval` (security risk, use alternatives like `getent`)
- Aliases in scripts (use functions)
- Unquoted variables in any context
- `function` keyword in declarations
- Backticks for command substitution

## References

- [ShellCheck](https://www.shellcheck.net/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
