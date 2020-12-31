import * as minimatch from "minimatch";

export const defaultPrereqPattern = "**";

/**
 * Check if any of the file paths match the file glob pattern.
 */
export function anyFileMatches(
  filePaths: readonly string[],
  pattern: string
): boolean {
  const regexp = minimatch.makeRe(pattern || "**");
  return filePaths.some((val) => regexp.test(val));
}

export function hasLabelMatch(labels: string[], skipLabel: string): boolean {
  return labels.includes(skipLabel);
}
