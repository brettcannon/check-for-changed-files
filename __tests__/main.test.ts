import * as main from "../src/main";

describe("repr()", () => {
  test("output quotes strings", () => {
    const result = main.repr("hello, world");
    expect(result).toBe('"hello, world"');
  });
});

describe("formatFailureMessage()", () => {
  test("prereq-pattern", () => {
    expect(
      main.formatFailureMessage("Hello, ${prereq-pattern}!", "world", "", "")
    ).toBe('Hello, "world"!');
  });

  test("file-pattern", () => {
    expect(
      main.formatFailureMessage("Hello, ${file-pattern}!", "", "world", "")
    ).toBe('Hello, "world"!');
  });

  test("skip-label", () => {
    expect(
      main.formatFailureMessage("Hello, ${skip-label}!", "", "", "world")
    ).toBe('Hello, "world"!');
  });

  test("all arguments", () => {
    const given =
      "prereq: ${prereq-pattern}, file: ${file-pattern}, label: ${skip-label}";
    const want =
      'prereq: "prereqPattern", file: "filePattern", label: "skipLabel"';
    expect(
      main.formatFailureMessage(
        given,
        "prereqPattern",
        "filePattern",
        "skipLabel"
      )
    ).toBe(want);
  });
});
