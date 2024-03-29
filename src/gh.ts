import * as github from "@actions/github";
import { Octokit } from "@octokit/core";
import { paginateRest } from "@octokit/plugin-paginate-rest";
import * as core from "@actions/core";

/**
 * The payload of a pull request event.
 *
 * Declared explicitly to make TypeScript happy and to avoid unnecessary undefined checks.
 */
interface PullRequestEvent {
  repository: {
    owner: {
      login: string;
    };
    name: string;
  };
  pull_request: {
    number: number;
    labels: [{ name: string }];
  };
}

/**
 * Check if `github.context.payload` is from a PR, returning it as the appropriate type.
 *
 * Returns `undefined` if the context is anything but a PR.
 */
export function pullRequestPayload(): PullRequestEvent | undefined {
  if (
    github.context.eventName === "pull_request" &&
    github.context.payload !== undefined &&
    github.context.payload.pull_request !== undefined &&
    github.context.payload.repository !== undefined
  ) {
    return github.context.payload as PullRequestEvent;
  }
  return undefined;
}

/**
 * Get the labels of the PR.
 */
export function pullRequestLabels(payload: PullRequestEvent): string[] {
  interface LabelData {
    name: string;
  }

  return payload.pull_request.labels.map(
    (labelData: LabelData) => labelData.name
  );
}

/**
 * Fetch the list of changed files in the PR.
 */
export async function changedFiles(
  payload: PullRequestEvent
): Promise<string[]> {
  const MyOctokit = Octokit.plugin(paginateRest);

  // Get the token from the inputs
  const token = core.getInput("token");

  const octokit = token ? new MyOctokit({ auth: token }) : new MyOctokit();

  return await octokit.paginate(
    "GET /repos/{owner}/{repo}/pulls/{pull_number}/files",
    {
      owner: payload.repository.owner.login,
      repo: payload.repository.name,
      pull_number: payload.pull_request.number,
      per_page: 100,
    },
    (response) => response.data.map((fileData) => fileData.filename)
  );
}
