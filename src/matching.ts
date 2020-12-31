import * as minimatch from "minimatch";

/** The default pattern for the `prereq-pattern` input. */
export const defaultPrereqPattern = "**";

/**
 * Check if any of the file paths match the file glob pattern.
 *
 * If `pattern` is falsy then `defaultPrereqPattern` is used. If `pattern` is multi-line,
 * then it is split and all lines are used to try to find a matching file path.
 */
export function anyFileMatches(
  filePaths: readonly string[],
  pattern: string
): boolean {
  const patterns: readonly string[] = pattern
    ? pattern.split("\n")
    : [defaultPrereqPattern];

  return patterns.some((pattern) => {
    const regexp = minimatch.makeRe(pattern, { dot: true });
    return filePaths.some((val) => regexp.test(val));
  });
}

/**
 * Check if the array of label names matches the specified skip label.
 */
export function hasLabelMatch(labels: string[], skipLabel: string): boolean {
  return labels.includes(skipLabel);
}
