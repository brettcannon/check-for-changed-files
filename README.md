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

### `prereq-pattern` (optional)

A pre-requisite glob pattern that, if specified, will cause the action to proceed
only if the pattern matches. If a match isn't found then the action is considered
successful.

See the notes about patterns for `file-pattern` for details on how matching
occurs and the flexibility in specifying the pattern.

### `skip-label` (optional)

The name of a label to forcibly skip the changed file check.

### `failure-message` (optional)

The message to emit when the check fails. All other inputs can be specified in
the message using `${}` syntax, e.g. `${file-pattern}` for the `file-pattern`
input. All values will be quoted for easy identification of any whitespace.

### `token` (optional)

A GitHub auth token to use for private repositories. Falls back to anonymous access if
not provided. Usually you want to use `${{ secrets.GITHUB_TOKEN }}` for this.

## Example usage (for requiring a news entry file)

E.g. for use with [scriv](https://scriv.readthedocs.io/):

```yaml
on:
  pull_request:
    types:
      # On by default if you specify no types.
      - "opened"
      - "reopened"
      - "synchronize"
      # For `skip-label` only.
      - "labeled"
      - "unlabeled"

jobs:
  ...
    ...
    steps:
      ...
      - name: "Check for news entry"
        uses: brettcannon/check-for-changed-files@v1
        with:
          file-pattern: "changelog.d/*.rst"
          skip-label: "skip news"
          failure-message: "Missing a news file in ${file-pattern}; please add one or apply the ${skip-label} label to the pull request"
```
