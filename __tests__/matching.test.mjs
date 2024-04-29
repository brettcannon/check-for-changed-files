import { describe, expect, test } from "vitest";
import * as matching from "../src/Matching.res.mjs";

const defaultPrereqPattern = "**";

describe("anyFileMatches()", () => {
  test("default prerequisite pattern for top-level files", () => {
    const filePaths = ["package-lock.json", "package.json", "README.md"];

    expect(
      matching.anyFileMatches(filePaths, defaultPrereqPattern)
    ).toBeTruthy();
  });

  test("default prerequisite pattern for files in subdirectories", () => {
    const filePaths = ["src/index.ts"];

    expect(
      matching.anyFileMatches(filePaths, defaultPrereqPattern)
    ).toBeTruthy();
  });

  test("default prerequisite pattern matches things in `.` subdirectories", () => {
    const filePaths = [".github/workflows/pull-request.yml"];

    expect(
      matching.anyFileMatches(filePaths, defaultPrereqPattern)
    ).toBeTruthy();
  });

  test("path literal matches", () => {
    const filePaths = ["package-lock.json", "package.json", "README.md"];
    const pathLiteral = "package.json";

    expect(matching.anyFileMatches(filePaths, pathLiteral)).toBeTruthy();
  });

  test("glob matches top-level file", () => {
    const filePaths = ["package-lock.json", "package.json", "README.md"];
    const glob = "package-*.json";

    expect(matching.anyFileMatches(filePaths, glob)).toBeTruthy();
  });

  test("glob matches subdirectory", () => {
    const filePaths = ["package.json", "src/index.ts"];
    const glob = "src/*.ts";

    expect(matching.anyFileMatches(filePaths, glob)).toBeTruthy();
  });

  test("glob does not match", () => {
    const filePaths = ["package-lock.json", "*", "package.json", "README.md"];
    const glob = "*.yml";

    expect(matching.anyFileMatches(filePaths, glob)).toBeFalsy();
  });

  test("mult-line patterns", () => {
    const filePaths = ["README.md", "package.json", "dist/index.js"];
    const glob = "package.json\npackage-lock.json";

    expect(matching.anyFileMatches(filePaths, glob)).toBeTruthy();
  });
});

describe("hasLabelMatch()", () => {
  test("no skip-label specified", () => {
    expect(matching.hasLabelMatch(["enhnacement"], "")).toBeFalsy();
  });

  test("skip-label does not match", () => {
    expect(
      matching.hasLabelMatch(["enhancement"], "skip package.json")
    ).toBeFalsy();
  });

  test("skip-label matches", () => {
    expect(
      matching.hasLabelMatch(
        ["enhancement", "skip package.json"],
        "skip packaging.json"
      )
    ).toBeFalsy();
  });
});
