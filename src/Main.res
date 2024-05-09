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

let main = async (): unit => {
  switch GH.pullRequestPayload() {
  | None => logInfo(`${repr(GH.actionContext["eventName"])} is not a pull request event; skipping`)
  | Some(payload) => {
      let skipLabel = GH.getInput("skip-label")
      let prLabels = GH.pullRequestLabels(payload)

      if Matching.hasLabelMatch(prLabels, skipLabel) {
        logInfo(`the skip label ${repr(skipLabel)} is set`)
      } else {
        let filePaths = await GH.changedFiles(payload)
        let prereqPattern = GH.getInput("prereq-pattern")

        if !Matching.anyFileMatches(filePaths, prereqPattern) {
          logInfo(
            `the prerequisite ${repr(
                prereqPattern,
              )} file pattern did not match any changed files of the pull request`,
          )
        } else {
          let filePattern = GH.getInput("file-pattern")

          if filePattern == "" {
            logFailure("The 'file-pattern' input was not specified")
          } else if Matching.anyFileMatches(filePaths, filePattern) {
            logInfo(
              `the ${repr(filePattern)} file pattern matched the changed files of the pull request`,
            )
          } else {
            let failureMessage = GH.getInput("failure-message")

            logFailure(
              formatFailureMessage(failureMessage, ~prereqPattern, ~filePattern, ~skipLabel),
            )
          }
        }
      }
    }
  }
}
