# check-for-changed-files Action

An action to check that PRs have changed certain files.

## Inputs

### `file-pattern`

**Required** The glob pattern for the file that must be changed by the PR.

### `prereq-pattern`

A pre-requisite glob pattern that, if specified, will cause the action to proceed
only if the pattern matches. If a match isn't found then the action is considered
successful.

### `skip-label`

The name of a label to forcibly skip the changed file check.

## Example usage

```yaml
on:
  pull_request:
    types:
      - "opened"
      - "reopened"
      - "synchronize"
      - "labeled"  # For `skip-label`.
      - "unlabeled"  # For `skip-label`.

jobs:
  ...
    ...
    uses: brettcannon/check-for-changed-files
    with:
      prereq-pattern: "package.json"
      file-pattern: "package-lock.json"
      skip-label: "skip package-lock.json"
```
