import * as github from "@actions/github";
import {
  afterAll,
  afterEach,
  beforeEach,
  describe,
  expect,
  test,
  vi,
} from "vitest";
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

  afterEach(() => vi.restoreAllMocks());

  test("pull_request context is returned by gh.pullRequestEvent()", () => {
    vi.spyOn(github, "context", "get").mockReturnValue(context);
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

  afterEach(() => vi.restoreAllMocks());

  test("'undefined' is returned by gh.pullRequestEvent()", () => {
    vi.spyOn(github, "context", "get").mockReturnValue(context);
    expect(gh.pullRequestPayload()).toBeUndefined();
  });
});
