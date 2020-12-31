# check-for-changed-files Action

An action to check that PRs have changed certain files.

## Inputs

### `file-pattern`

**Required** The glob pattern for the file that must be changed by the PR.

### `prereq-pattern`

Pre-requisite glob pattern that, if specified and it matches, the action runs.
If the pattern is defined and it does not match, the action is considered passing.
Not specifying the pattern means implicitly that it "matches".

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
