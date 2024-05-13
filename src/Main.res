@module("@actions/core") external logInfo: string => unit = "info"
@module("@actions/core") external logFailure: string => unit = "setFailed"

/**
 Get a quoted version of a string.
 */
let repr = str => JSON.Encode.string(str)->JSON.stringify

/**
 Format a failure message based on the template provided.
 */
let formatFailureMessage = (template, ~prereqPattern, ~filePattern, ~skipLabel) =>
  template
  ->String.replaceAll("${prereq-pattern}", repr(prereqPattern))
  ->String.replaceAll("${file-pattern}", repr(filePattern))
  ->String.replaceAll("${skip-label}", repr(skipLabel))

/**
 Check if `skip-labels` did NOT match.
 */
let noSkipLabelMatch = (payload, ~_getInputImpl=GH.getInput, ~_logInfoImpl=logInfo) => {
  let skipLabel = _getInputImpl("skip-label")
  // Because unset inputs default to `""`, this check will implicitly fail if no label is
  // specified.
  let prLabels = GH.pullRequestLabels(payload)

  if Matching.hasLabelMatch(prLabels, skipLabel) {
    _logInfoImpl(`the skip label ${repr(skipLabel)} is set`)
    None
  } else {
    Some(skipLabel)
  }
}

/**
 Check if the file paths match `prereq-pattern`.
 */
let pathsMatchPrereqPattern = (
  filePaths,
  ~_getInputImpl=GH.getInput,
  ~_logInfoImpl=logInfo,
): option<string> => {
  let prereqPattern = _getInputImpl("prereq-pattern")
  let matches = Matching.anyFileMatches(filePaths, prereqPattern)

  if !matches {
    _logInfoImpl(
      `the prerequisite ${repr(
          prereqPattern,
        )} file pattern did not match any changed files of the pull request`,
    )

    None
  } else {
    Some(prereqPattern)
  }
}

/**
 Log if the file paths match `file-pattern`.
 */
let pathsMatchFilePattern = (
  filePaths,
  ~prereqPattern,
  ~skipLabel,
  ~_getInputImpl=GH.getInput,
  ~_logInfoImpl=logInfo,
  ~_logFailureImpl=logFailure,
): unit => {
  let filePattern = _getInputImpl("file-pattern")

  if filePattern == "" {
    _logFailureImpl("The 'file-pattern' input was not specified")
  } else if Matching.anyFileMatches(filePaths, filePattern) {
    _logInfoImpl(
      `the ${repr(filePattern)} file pattern matched the changed files of the pull request`,
    )
  } else {
    let failureMessage = GH.getInput("failure-message")

    _logFailureImpl(formatFailureMessage(failureMessage, ~prereqPattern, ~filePattern, ~skipLabel))
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
    switch payload->noSkipLabelMatch {
    | None => ()
    | Some(skipLabel) => {
        let filePaths = await GH.changedFiles(payload)

        switch filePaths->pathsMatchPrereqPattern {
        | None => ()
        | Some(prereqPattern) => filePaths->pathsMatchFilePattern(~prereqPattern, ~skipLabel)
        }
      }
    }
  }
}
