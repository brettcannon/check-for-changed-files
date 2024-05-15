@module("@actions/core") external logInfo: string => unit = "info"
@module("@actions/core") external logFailure: string => unit = "setFailed"

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
  let prLabels = GH.pullRequestLabels(payload)

  Matching.hasLabelMatch(prLabels, inputs.skipLabel)
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
): unit => {
  if inputs.filePattern == "" {
    _logFailureImpl("The 'file-pattern' input was not specified")
  } else if Matching.anyFileMatches(filePaths, inputs.filePattern) {
    _logInfoImpl(
      `the ${repr(inputs.filePattern)} file pattern matched the changed files of the pull request`,
    )
  } else {
    _logFailureImpl(inputs->formatFailureMessage)
  }
}

let main = async (): unit => {
  switch GH.pullRequestPayload() {
  | None =>
    logInfo(
      `${repr(
          (GH.actionContext["eventName"] :> string),
        )} is not a full 'pull_request' event; skipping`,
    )
  | Some(payload) =>
    let inputs = Action.inputs()

    switch payload->skipLabelMatch(inputs) {
    | true => logInfo(`the skip label ${repr(inputs.skipLabel)} is set`)
    | false => {
        let filePaths = await GH.changedFiles(payload)

        switch filePaths->pathsMatchPreReqPattern(inputs) {
        | false =>
          logInfo(
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
