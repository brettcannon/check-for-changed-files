import * as minimatch from "minimatch";

export function matches(
  filePaths: readonly string[],
  requiredGlob: string
): boolean {
  const matches = minimatch.match(filePaths, requiredGlob, { nonull: false });
  return matches.length != 0;
}
