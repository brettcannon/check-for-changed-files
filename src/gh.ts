import * as github from "@actions/github";
import { Octokit } from "@octokit/core";
import { paginateRest } from "@octokit/plugin-paginate-rest";
import { EventPayloads } from "@octokit/webhooks";

function isPullRequest(
  eventName: string,
  payload: typeof github.context.payload
): payload is EventPayloads.WebhookPayloadPullRequest {
  return eventName === "pull_request";
}

/**
 * Check if `github.context.payload` is from a PR, returning it as the appropriate type.
 *
 * Returns `undefined` if the context is anything but a PR.
 */
export function pullRequestPayload():
  | EventPayloads.WebhookPayloadPullRequest
  | undefined {
  if (isPullRequest(github.context.eventName, github.context.payload)) {
    return github.context.payload;
  }
  return undefined;
}

/**
 * Get the labels of the PR.
 */
export function pullRequestLabels(
  payload: EventPayloads.WebhookPayloadPullRequest
): string[] {
  return payload.pull_request.labels.map((labelData) => labelData.name);
}

/**
 * Fetch the list of changed files in the PR.
 */
export async function changedFiles(
  payload: EventPayloads.WebhookPayloadPullRequest
): Promise<string[]> {
  const MyOctokit = Octokit.plugin(paginateRest);
  const octokit = new MyOctokit(); // Anonymous to avoid asking for an access token.

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
