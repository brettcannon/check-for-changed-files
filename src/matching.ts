import * as minimatch from "minimatch";

export function match(
  filePaths: readonly string[],
  requiredGlob: string
): boolean {
  const matches = minimatch.match(filePaths, requiredGlob, { nonull: false });
  return matches.length != 0;
}
