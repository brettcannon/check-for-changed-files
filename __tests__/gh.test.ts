import { ImportMock } from "ts-mock-imports";
import * as github from "@actions/github";
import * as gh from "../src/gh";

test("gh.pullRequestEvent() return undefined by default", () => {
  expect(gh.pullRequestPayload()).toBeUndefined();
});

describe("Stub github.context w/ a pull_request payload", () => {
  beforeEach(() => {
    const context = { eventName: "pull_request", payload: { number: 42 } };
    ImportMock.mockOther(github, "context", context);
  });
  afterEach(() => ImportMock.restore());

  test("pull_request context is returned by gh.pullRequestEvent()", () => {
    expect(gh.pullRequestPayload()).toEqual({ number: 42 });
  });
});

describe("Stub github.context w/ a 'push' payload", () => {
  beforeEach(() => {
    const context = { eventName: "push", payload: { number: 42 } };
    ImportMock.mockOther(github, "context", context);
  });
  afterEach(() => ImportMock.restore());

  test("'undefined' is returned by gh.pullRequestEvent()", () => {
    expect(gh.pullRequestPayload()).toBeUndefined();
  });
});
