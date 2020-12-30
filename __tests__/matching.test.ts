import * as matching from "../src/matching";

test("path literal matches", () => {
  const filePaths = ["package-lock.json", "package.json", "README.md"];
  const pathLiteral = "package.json";
  expect(matching.match(filePaths, pathLiteral)).toBeTruthy();
});

test("glob matches", () => {
  const filePaths = ["package-lock.json", "package.json", "README.md"];
  const glob = "package-*.json";
  expect(matching.match(filePaths, glob)).toBeTruthy();
});

test("glob does not match", () => {
  const filePaths = ["package-lock.json", "package.json", "README.md"];
  const glob = "*.yml";
  expect(matching.match(filePaths, glob)).toBeFalsy();
});
