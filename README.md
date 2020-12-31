# check-for-changed-files Action

An action to check that PRs have changed certain files.

## Inputs

### `file-pattern`

**Required** The glob pattern for the file(s) that must be changed by the PR.

The glob patterns are matched using
[minimatch](https://www.npmjs.com/package/minimatch) with `{dot: true}` options.
As well, multiple lines in the input are supported, and each line is treated
as its own glob pattern. E.g.:

```yaml
file-pattern: |
  package.json
  package-lock.json
```

acts as two patterns: `package.json` and `package-lock.json`. Success occurs if
_any_ of the patterns match.

### `prereq-pattern`

A pre-requisite glob pattern that, if specified, will cause the action to proceed
only if the pattern matches. If a match isn't found then the action is considered
successful.

See the notes about patterns for `file-pattern` for details on how matching
occurs and flexibility in specifying the pattern.

### `skip-label`

The name of a label to forcibly skip the changed file check.

## Example usage (for requiring a news entry file)

E.g. for use with [scriv](https://scriv.readthedocs.io/):

```yaml
on:
  pull_request:
    types:
      # On by default if you specify no types.
      - "opened"
      - "synchronize"
      # For `skip-label` only.
      - "labeled"
      - "unlabeled"

jobs:
  ...
    ...
    name: "Check for news entry"
    uses: brettcannon/check-for-changed-files
    with:
      file-pattern: "changelog.d/*.rst"
      skip-label: "skip news"
```
