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

type eventName = [
  | #branch_protection_rule
  | #check_run
  | #check_suite
  | #create
  | #delete
  | #deployment
  | #deployment_status
  | #discussion
  | #discussion_comment
  | #fork
  | #gollum
  | #issue_comment
  | #issues
  | #label
  | #merge_group
  | #milestone
  | #page_build
  | #project
  | #project_card
  | #project_column
  | #public
  | #pull_request
  | #pull_request_comment
  | #pull_request_review
  | #pull_request_review_comment
  | #pull_request_target
  | #push
  | #registry_package
  | #release
  | #repository_dispatch
  | #schedule
  | #status
  | #watch
  | #workflow_call
  | #workflow_dispatch
  | #workflow_run
]

/**
 Object type for the context of the action.

 Specified as an object for consistency with payloadType.
 */
type contextType = {"eventName": eventName, "payload": option<payloadType>}

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

/**
 Opaque type for an Octokit object.
 */
type octokitType

@module("@actions/github") external actionContext: contextType = "context"
@send
external paginate: (
  octokitType, // Too much of a pain to type.
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
let pullRequestPayload = (~context=actionContext) => {
  let payload = context["payload"]->Option.getOr({"pull_request": None, "repository": None})
  switch (payload["pull_request"], payload["repository"]) {
  | (Some(pr), Some(repo)) if context["eventName"] == #pull_request =>
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

%%private(
  // While marked as ignored to shut the commpiler up,
  // `_token` is used inside the %raw() call (see the JS output to verify).
  let makeOctokit = _token => {
    switch _token {
    | None => %raw(`new (Octokit.plugin(paginateRest))()`)
    | Some(_token) => %raw(`new (Octokit.plugin(paginateRest))({ auth: _token })`)
    }
  }
)

/**
 * Fetch the list of changed files in the PR.
 */
let changedFiles = async (payload, inputs: Action.inputsType) => {
  await inputs.token
  ->makeOctokit
  ->paginate(
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
