import * as minimatch from "minimatch";

/**
 * Check if any of the file paths match the file glob pattern.
 *
 * If `pattern` is falsy then `defaultPrereqPattern` is used. If `pattern` is multi-line,
 * then it is split and all lines are used to try to find a matching file path.
 */
export function anyFileMatches(filePaths, pattern) {
  const patterns = pattern.split("\n");

  return patterns.some((pattern) => {
    const regexp = minimatch.makeRe(pattern, { dot: true });
    return filePaths.some((val) => regexp.test(val));
  });
}

/**
 * Check if the array of label names matches the specified skip label.
 */
export function hasLabelMatch(labels, skipLabel) {
  return labels.includes(skipLabel);
}
