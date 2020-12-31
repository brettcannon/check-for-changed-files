# check-for-changed-files Action

An action to check that PRs have changed certain files.

## Inputs

### `file-pattern`

**Required** The glob pattern for the file that must be changed by the PR.

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
      file-pattern: "package.json"
      skip-label: "skip package.json"
```
