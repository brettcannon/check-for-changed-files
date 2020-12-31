import * as minimatch from "minimatch";

/**
 * Check if any of the file paths match the file glob pattern.
 */
export function hasFileMatch(
  filePaths: readonly string[],
  filePattern: string
): boolean {
  const matches = minimatch.match(filePaths, filePattern, { nonull: false });
  return matches.length != 0;
}

export function hasLabelMatch(labels: string[], skipLabel: string): boolean {
  return labels.includes(skipLabel);
}
