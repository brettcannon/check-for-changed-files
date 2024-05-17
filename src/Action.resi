type inputsType = {
  filePattern: string,
  preReqPattern: string,
  skipLabel: string,
  failureMessage: string,
  token: string,
}

let inputs: unit => inputsType
