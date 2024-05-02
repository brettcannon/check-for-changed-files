/* TODO
  - Isolate %raw() code into its own function so its more isolated/obvious
  - Wrap getInput() into a function that returns option<string> and has an optional trimWhitespace parameter;
    https://github.com/actions/toolkit/blob/ae38557bb0dba824cdda26ce787bd6b66cf07a83/packages/core/src/core.ts#L126-L138
*/

/**
 Labels in a PR.
 */
type labelType = {name: string}

/**
 Critical info from a pull request payload.
 */
type prType = {
  number: int,
  labels: array<labelType>,
}

/**
 The owner or a repository.
 */
type ownerType = {login: string}

/**
 The repository details for a payload.
 */
type repoType = {
  name: string,
  owner: ownerType,
}

/**
 A payload type that avoids having to go through `option` on all accesses.
 */
type prPayloadType = {
  pull_request: prType,
  repository: repoType,
}

/**
 Payload object type to be used by `context`.

 Specified as an object to avoid confusion with prPayloadType which is a record.
 */
type payloadType = {"pull_request": option<prType>, "repository": option<repoType>}

/**
 Object type for the context of the action.

 Specified as an object for consistency with payloadType.
 */
type contextType = {"eventName": string, "payload": option<payloadType>}

/**
 Options for `paginate()`.
 */
type paginateOptionsType = {
  owner: string,
  repo: string,
  pull_number: int,
  per_page: int,
}

/**
 File data passed into the processing function for `paginate()`.
 */
type fileDataType = {filename: string}

/**
 The type being passed into the processing function for `paginate()`.
 */
type paginateResponseType = {data: array<fileDataType>}

type paginateReturnType = array<string>

/**
 The function passed into `paginate()` to process the results.
 */
type paginateProcessType = paginateResponseType => paginateReturnType

@module("@actions/github") external context: contextType = "context"
@module("@actions/core") external getInput: string => string = "getInput"
@send
external paginate: (
  'octokit, // Too much of a pain to type.
  string,
  paginateOptionsType,
  paginateProcessType,
) => promise<paginateReturnType> = "paginate"
// Imports used only inside %raw calls; doing this in ReScript would cause the
// compiler to drop the imports as unnecessary.
%%raw(`
import { Octokit } from "@octokit/core";
import { paginateRest } from "@octokit/plugin-paginate-rest";
`)

/**
 * Check if `github.context.payload` is from a PR, returning it as the appropriate type.
 *
 * Returns `undefined` if the context is anything but a PR.
 */
let pullRequestPayload = () => {
  let payload = context["payload"]->Option.getOr({"pull_request": None, "repository": None})

  switch (payload["pull_request"], payload["repository"]) {
  | (Some(pr), Some(repo)) if context["eventName"] == "pull_request" =>
    Some({
      pull_request: pr,
      repository: repo,
    })
  | _ => None
  }
}

/**
 * Get the labels of the PR.
 */
let pullRequestLabels = payload =>
  payload.pull_request.labels->Array.map(labelData => labelData.name)

/**
 * Fetch the list of changed files in the PR.
 */
let changedFiles = async payload => {
  let octokit = switch getInput("token") {
  | "" => %raw(`new (Octokit.plugin(paginateRest))()`)
  // While marked as ignored, `_token` is used inside the %raw() call.
  | _token => %raw(`new (Octokit.plugin(paginateRest))({ auth: _token })`)
  }

  await octokit->paginate(
    "GET /repos/{owner}/{repo}/pulls/{pull_number}/files",
    {
      owner: payload.repository.owner.login,
      repo: payload.repository.name,
      pull_number: payload.pull_request.number,
      per_page: 100,
    },
    response => response.data->Array.map(fileData => fileData.filename),
  )
}
