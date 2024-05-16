type logMessage = string

@module("@actions/core") external logInfo: logMessage => unit = "info"
@module("@actions/core") external logFailure: logMessage => unit = "setFailed"

/**
 Get a quoted version of a string.
 */
let repr = str => JSON.Encode.string(str)->JSON.stringify

/**
 Format a failure message based on the template provided.
 */
let formatFailureMessage = (inputs: Action.inputsType) =>
  inputs.failureMessage
  ->String.replaceAll("${prereq-pattern}", repr(inputs.preReqPattern))
  ->String.replaceAll("${file-pattern}", repr(inputs.filePattern))
  ->String.replaceAll("${skip-label}", repr(inputs.skipLabel))

/**
 Check if `skip-labels` did NOT match.
 */
let skipLabelMatch = (payload, inputs: Action.inputsType) => {
  // Because unset inputs default to `""`, this check will implicitly fail if no label is
  // specified.
  payload->GH.pullRequestLabels->Matching.hasLabelMatch(inputs.skipLabel)
}

/**
 Check if the file paths match `prereq-pattern`.
 */
let pathsMatchPreReqPattern = (filePaths, inputs: Action.inputsType) =>
  filePaths->Matching.anyFileMatches(inputs.preReqPattern)

/**
 Log if the file paths match `file-pattern`.
 */
let pathsMatchFilePattern = (
  filePaths,
  inputs: Action.inputsType,
  ~_logInfoImpl=logInfo,
  ~_logFailureImpl=logFailure,
) => {
  if inputs.filePattern == "" {
    Error("The 'file-pattern' input was not specified")
  } else if Matching.anyFileMatches(filePaths, inputs.filePattern) {
    Ok(`the ${repr(inputs.filePattern)} file pattern matched the changed files of the pull request`)
  } else {
    Error(inputs->formatFailureMessage)
  }
}

// TODO consider inlining logic functions
/**
 Check if the workflow has succeeded in passing the check.
 */
let checkforChangedFiles = async (payload, inputs, ~_changedFilesImpl=GH.changedFiles): result<
  logMessage,
  logMessage,
> => {
  switch payload {
  | None =>
    Ok(
      `${repr(
          (GH.actionContext["eventName"] :> string),
        )} is not a full 'pull_request' event; skipping`,
    )
  | Some(payload) =>
    switch payload->skipLabelMatch(inputs) {
    | true => Ok(`the skip label ${repr(inputs.skipLabel)} is set`)
    | false => {
        let filePaths = await _changedFilesImpl(payload)

        switch filePaths->pathsMatchPreReqPattern(inputs) {
        | false =>
          Ok(
            `the prerequisite ${repr(
                inputs.preReqPattern,
              )} file pattern did not match any changed files of the pull request`,
          )
        | true => filePaths->pathsMatchFilePattern(inputs)
        }
      }
    }
  }
}

let main = async (): unit => {
  let payload = GH.pullRequestPayload()
  let inputs = Action.inputs()

  switch await payload->checkforChangedFiles(inputs) {
  | Ok(message) => logInfo(message)
  | Error(message) => logFailure(message)
  }
}
