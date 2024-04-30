/* TODO
  - Isolate %raw() code into its own function so its more isolated/obvious
  - Wrap getInput() into a function that returns option<string>
  - Type `context`/contextType so that the "pull_request" and "repository" are optional, but not subfields
  - Type the pullRequestPayloadType so that "pull_request" and "repository" are required
  - pullRequestPayload() return `option<pullRequestPayloadType>`
  - Type paginate() better
 */

@module("@actions/github") external context: 'whatever = "context"
@module("@actions/core") external getInput: string => string = "getInput"
@send external paginate: ('a, 'b, 'c, 'd) => promise<array<string>> = "paginate"
// Imports used only inside %raw calls; doing this in ReScript would cause the
// compiler to drop the imports as unnecessary.
%%raw(`
import { Octokit } from "@octokit/core";
import { paginateRest } from "@octokit/plugin-paginate-rest";
`)

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

/**
 * Fetch the list of changed files in the PR.
 */
let changedFiles = async payload => {
  let octokit = switch getInput("token") {
  | "" => %raw(`new Octokit.plugin(paginateRest)()`)
  // While marked as ignored, `_token` is used inside the %raw() call.
  | _token => %raw(`new Octokit.plugin(paginateRest)({ auth: _token })`)
  }

  await octokit->paginate(
    "GET /repos/{owner}/{repo}/pulls/{pull_number}/files",
    {
      "owner": payload["repository"]["owner"]["login"],
      "repo": payload["repository"]["name"],
      "pull_number": payload["pull_request"]["number"],
      "per_page": 100,
    },
    response => response["data"]->Array.map(fileData => fileData["filename"]),
  )
}
