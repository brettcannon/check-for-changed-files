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

export function pullRequestPayload():
  | EventPayloads.WebhookPayloadPullRequest
  | undefined {
  if (isPullRequest(github.context.eventName, github.context.payload)) {
    return github.context.payload;
  }
  return undefined;
}

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
