/* TODO
  - Isolate %raw() code into its own function so its more isolated/obvious
  - Wrap getInput() into a function that returns option<string>
*/

type labelType = {name: string}

type prType = {
  number: int,
  labels: array<labelType>,
}

type ownerType = {login: string}

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

type payloadType = {
  pull_request: option<prType>,
  repository: option<repoType>,
}
type contextType = {
  eventName: string,
  payload: option<payloadType>,
}

type paginateOptionType = {
  owner: string,
  repo: string,
  pull_number: int,
  per_page: int,
}

type fileDataType = {filename: string}

type paginateResponseType = {data: array<fileDataType>}

type paginateReturnType = array<string>

type paginateCallbackType = paginateResponseType => paginateReturnType

@module("@actions/github") external context: contextType = "context"
@module("@actions/core") external getInput: string => string = "getInput"
@send
external paginate: (
  'octokit,
  string,
  paginateOptionType,
  paginateCallbackType,
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
let pullRequestPayload = (): option<prPayloadType> => {
  let payload = context.payload->Option.getOr({pull_request: None, repository: None})

  switch payload {
  | {pull_request: Some(pr), repository: Some(repo)} if context.eventName == "pull_request" => {
      let prPayload: prPayloadType = {pull_request: pr, repository: repo}
      Some(prPayload)
    }
  | _ => None
  }
}

/**
 * Get the labels of the PR.
 */
let pullRequestLabels = (payload: prPayloadType) =>
  payload.pull_request.labels->Array.map(labelData => labelData.name)

/**
 * Fetch the list of changed files in the PR.
 */
let changedFiles = async (payload: prPayloadType) => {
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
