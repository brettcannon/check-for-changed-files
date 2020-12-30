# check-for-changed-files Action

An action to check that PRs have changed certain files.

## Inputs

### `file-glob`

**Required** The glob pattern for the file that must be changed by the PR.

## Example usage

```yaml
uses: brettcannon/check-for-changed-files
with:
  file-glob: "package.json"
```
