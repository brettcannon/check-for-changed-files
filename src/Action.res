type inputsType = {
  filePattern: string,
  preReqPattern: string,
  skipLabel: string,
  failureMessage: string,
  token: string,
}

@module("@actions/core")
external getInput: string => string = "getInput"

let inputs = () => {
  filePattern: getInput("file-pattern"),
  preReqPattern: getInput("prereq-pattern"),
  skipLabel: getInput("skip-label"),
  token: getInput("token"),
  failureMessage: getInput("failure-message"),
}
