@module("minimatch") external reFromGlob: (string, @as(json`{"dot": true}`) _) => Re.t = "makeRe"

/**
 * Check if any of the file paths match the file glob pattern.
 *
 * If 'pattern' is multi-line, then it is split and all lines are used to try to find a
 * matching file path.
 */
let anyFileMatches = (filePaths: array<string>, pattern: string) =>
  pattern
  ->String.split("\n")
  ->Array.some(pattern => {
    let regexp = reFromGlob(pattern)
    filePaths->Array.some(val => regexp->Re.test(val))
  })

/**
 * Check if the array of label names matches the specified skip label.
 */
let hasLabelMatch = (labels: array<string>, skipLabel: string) =>
  labels->Array.indexOfOpt(skipLabel)->Option.isSome
