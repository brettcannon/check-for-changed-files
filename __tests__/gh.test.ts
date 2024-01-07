import { ImportMock } from "ts-mock-imports";
import * as github from "@actions/github";
import * as gh from "../src/gh";

test("gh.pullRequestEvent() return undefined by default", () => {
  expect(gh.pullRequestPayload()).toBeUndefined();
});

describe("Stub github.context w/ a pull_request payload", () => {
  const context = {
    eventName: "pull_request",
    payload: {
      pull_request: { number: 42 },
      repository: { name: "test", owner: { login: "anonymous" } },
    },
  };

  beforeEach(() => {
    ImportMock.mockOther(github, "context", context);
  });
  afterEach(() => ImportMock.restore());

  test("pull_request context is returned by gh.pullRequestEvent()", () => {
    expect(gh.pullRequestPayload()).toEqual(context.payload);
  });
});

describe("Stub github.context w/ a 'push' payload", () => {
  const context = {
    eventName: "push",
    payload: {
      pull_request: { number: 42 },
      repository: { name: "test", owner: { login: "anonymous" } },
    },
  };
  beforeEach(() => {
    ImportMock.mockOther(github, "context", context);
  });
  afterEach(() => ImportMock.restore());

  test("'undefined' is returned by gh.pullRequestEvent()", () => {
    expect(gh.pullRequestPayload()).toBeUndefined();
  });
});
