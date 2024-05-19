type inputsType = {
  filePattern: string,
  preReqPattern: string,
  skipLabel: option<string>,
  failureMessage: string,
  token: option<string>,
}

// Could use a `.resi` file to control visibility, but it requires repeating
// `inputsType` in the `.resi` file.
%%private(
  @module("@actions/core")
  external getInput: string => string = "getInput"
)

let inputs = () => {
  let maybe = val => {
    if val != "" {
      Some(val)
    } else {
      None
    }
  }

  {
    filePattern: getInput("file-pattern"),
    preReqPattern: getInput("prereq-pattern"),
    failureMessage: getInput("failure-message"),
    skipLabel: getInput("skip-label")->maybe,
    token: getInput("token")->maybe,
  }
}
