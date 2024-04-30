@module("@actions/github") external context: 'whatever = "context"

/**
 * Check if 'github.context.payload' is from a PR, returning it as the appropriate type.
 *
 * Returns 'undefined' if the context is anything but a PR.
 */
let pullRequestPayload = () => {
  if (
    context["eventName"] == "pull_request" &&
    context["payload"] != Nullable.undefined &&
    context["payload"]["pull_request"] != Nullable.undefined &&
    context["payload"]["repository"] != Nullable.undefined
  ) {
    // TODO: Can return a specific pullRequestPayloadType to avoid deeply nested option access.
    context["payload"]
  } else {
    None
  }
}

/**
 * Get the labels of the PR.
 */
let pullRequestLabels = payload =>
  payload["pull_request"]["labels"]->Array.map(labelData => labelData["name"])

// TODO: consider doing an octokit FFI function as the dynamism is so extreme it's hard to model.
%%raw(`
import { Octokit } from "@octokit/core";
import { paginateRest } from "@octokit/plugin-paginate-rest";
import * as core from "@actions/core";

/**
 * Fetch the list of changed files in the PR.
 */
export async function changedFiles(payload) {
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

`)
