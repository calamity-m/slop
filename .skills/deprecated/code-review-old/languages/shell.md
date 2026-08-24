# Shell Language Lens

Review shell scripts for quoting discipline, failure handling, unsafe filesystem operations, portability lies, and untestable structure. Applies to Bash and POSIX sh; note which dialect the script declares.

## Quoting and Word Splitting

- Unquoted variable expansions are the default shell bug. Flag `$var`, `$@`, `$(cmd)` unquoted anywhere the value could contain spaces, globs, or be empty — paths, user input, and command output especially.
- Flag `$*` where `"$@"` is meant; `$*` joins arguments and breaks any caller passing paths with spaces.
- Flag `for f in $(ls ...)` and `for f in $(find ...)` — word splitting mangles filenames. Suggest globs, `find -print0 | while read -d ''`, or arrays.
- Flag `[ $x = "y" ]` where an empty `$x` produces a syntax error; suggest quoting or `[[ ]]` in Bash.
- Flag `eval` on any string containing external data. If `eval` is unavoidable, the reviewed code must show why the input is trusted.

## Failure Handling

- Every script should declare its failure posture. Flag scripts with no `set -e`/`set -u`/`set -o pipefail` and no visible per-command error checking — silent partial execution is the failure mode.
- `set -e` is not a safety net: it is disabled inside `if` conditions, `&&`/`||` chains, and command substitutions in some shells. Flag code that relies on `set -e` to catch failures in those positions.
- Flag `cmd1 | cmd2` where `cmd1` failing matters and `pipefail` is not set — the pipeline reports only `cmd2`'s status.
- Flag `cd somewhere` without failure handling when later commands assume the new directory — `cd foo || exit 1` or `set -e` with a direct `cd`. An unchecked failed `cd` turns a scoped operation into one running in the wrong directory.
- Flag `local var=$(cmd)` — `local` masks the command's exit status. Declare and assign separately when the status matters.
- Flag exit codes swallowed by `$(...)` assignments where the result is used unconditionally.

## Unsafe Filesystem Operations

- Flag `rm -rf` on any path built from a variable that could be empty or unset — `rm -rf "$dir/"` with empty `dir` deletes `/`. Require `set -u`, `${dir:?}`, or an explicit emptiness check first.
- Flag predictable temp paths like `/tmp/myscript.$$` — use `mktemp`/`mktemp -d`, and clean up with a `trap ... EXIT`.
- Flag scripts that overwrite or delete existing user files without a guard or an explicit force flag; the conservative default is to skip and report.
- Flag `curl ... | sh` or sourcing downloaded content without a checksum or pinned ref.

## Portability and Dialect

- The shebang is a contract. Flag Bash-only constructs (`[[ ]]`, arrays, `local`, `${var//pat/rep}`, process substitution) in scripts declaring `#!/bin/sh`.
- Flag `#!/usr/bin/env bash` vs `#!/bin/bash` inconsistency within a codebase — match the siblings.
- Flag reliance on GNU-only flags (`sed -i` without suffix, `readlink -f`, `grep -P`) when the script claims macOS/BSD support; ignore this when the codebase is explicitly Linux-only.
- Flag parsing `ls` output or depending on locale-sensitive sort order.

## Structure and Testability

- Flag scripts where all logic runs at top level with no functions once they pass roughly a screenful — functions give named units, early returns, and `bash -n`/shellcheck something to anchor to.
- Flag copy-pasted command blocks that differ only by a path or flag; a small function with parameters is the fix.
- Flag environment-variable dependencies that are read deep inside the script with no default and no mention in usage/help text.
- Flag missing or stale usage/help text on scripts that take flags.
- If the codebase uses `shellcheck`, flag new warnings it would raise; if it doesn't, note that as a gap rather than re-deriving every rule by hand.

## Good Findings

- `rm -rf "$BUILD_DIR/out"` where `BUILD_DIR` comes from an env var and `set -u` is not set
- `for f in $(find . -name '*.log')` breaking on any filename with a space
- A `#!/bin/sh` script using `[[ ]]` and arrays — works locally, breaks on dash
- A pipeline `gen_data | transform > out` treated as success when `gen_data` fails, because `pipefail` is unset
- `cd "$repo_dir"` unchecked, followed by `git clean -fd`
- `local result=$(risky_cmd)` followed by code that assumes `risky_cmd` succeeded

## Weak Findings to Avoid

- Demanding POSIX portability for a script that declares `#!/usr/bin/env bash` in a Bash-only codebase
- Flagging unquoted expansions of variables the script itself sets to known-safe constants
- Blanket "add set -euo pipefail" advice on scripts whose per-command error handling is already explicit and correct
- Style-only complaints (backticks vs `$()`, `function` keyword) with no correctness consequence, unless siblings establish a convention
