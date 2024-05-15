type inputsType = {
  filePattern: string,
  preReqPattern: string,
  skipLabel: string,
  failureMessage: string,
  token: string,
}

@module("@actions/core")
external getInput: @string
[
  | @as("file-pattern") #filePattern
  | @as("prereq-pattern") #preReqPattern
  | @as("skip-label") #skipLabel
  | @as("failure-message") #failureMessage
  | #token
] => string = "getInput"

let inputs = () => {
  filePattern: getInput(#filePattern),
  preReqPattern: getInput(#preReqPattern),
  skipLabel: getInput(#skipLabel),
  token: getInput(#token),
  failureMessage: getInput(#failureMessage),
}
