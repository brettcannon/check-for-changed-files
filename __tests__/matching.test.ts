import * as matching from "../src/matching";

describe("hasFileMatch", () => {
  test("path literal matches", () => {
    const filePaths = ["package-lock.json", "package.json", "README.md"];
    const pathLiteral = "package.json";
    expect(matching.hasFileMatch(filePaths, pathLiteral)).toBeTruthy();
  });

  test("glob matches", () => {
    const filePaths = ["package-lock.json", "package.json", "README.md"];
    const glob = "package-*.json";
    expect(matching.hasFileMatch(filePaths, glob)).toBeTruthy();
  });

  test("glob does not match", () => {
    const filePaths = ["package-lock.json", "package.json", "README.md"];
    const glob = "*.yml";
    expect(matching.hasFileMatch(filePaths, glob)).toBeFalsy();
  });
});

describe("hasLabelMatch", () => {
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
