open Zora

zora("formatFailureMessage()", async t => {
  t->test("arguments used", async t => {
    let template = "${prereq-pattern} ${file-pattern} ${skip-label}"
    let preReqPattern = TestUtils.randomString()
    let filePattern = TestUtils.randomString()
    let skipLabel = TestUtils.randomString()

    let inputs: Action.inputsType = {
      failureMessage: template,
      preReqPattern,
      filePattern,
      skipLabel: Some(skipLabel),
      token: None,
    }

    let errorMessage = inputs->Main.formatFailureMessage

    t->ok(errorMessage->String.includes(preReqPattern))
    t->ok(errorMessage->String.includes(filePattern))
    t->ok(errorMessage->String.includes(skipLabel))

    t->notOk(errorMessage->String.includes("${prereq-pattern}"))
    t->notOk(errorMessage->String.includes("${file-pattern}"))

    t->notOk(errorMessage->String.includes("${skip-label}"))
  })
})

zora("checkForChangedFiles()", async t => {
  let okContains = (t, given: result<string, 'b>, expected: string) =>
    t->resultOk(given, (t, r) =>
      t->ok(r->String.includes(expected), ~msg=`log message should contain "${expected}"`)
    )

  // Default test data should cause a failure, forcing tests to change things
  // to having the test pass.
  let pull_request: GH.prType = {
    number: 1234,
    labels: [{name: "Label A"}],
  }

  let repository: GH.repoType = {
    name: "check-for-changed-files",
    owner: {login: "brettcannon"},
  }

  let payload: option<GH.prPayloadType> = Some({pull_request, repository})

  let inputs: Action.inputsType = {
    filePattern: "Dir2/B",
    preReqPattern: "**",
    skipLabel: Some("Label B"),
    failureMessage: "${prereq-pattern} ${file-pattern} ${skip-label}",
    token: None,
  }

  let fakeChangedFiles = async (_, _) => ["Dir3/C"]

  t->test("not a pull request", async t => {
    let inputs: Action.inputsType = {
      filePattern: "Dir1/B",
      preReqPattern: "**",
      skipLabel: None,
      failureMessage: "${prereq-pattern} ${file-pattern} ${skip-label}",
      token: None,
    }

    t->okContains(await None->Main.checkforChangedFiles(inputs), "pull_request")
  })

  t->test("skip label set", async t => {
    let skipLabel = "Label A"
    let inputs = {...inputs, skipLabel: Some(skipLabel)}

    t->okContains(
      await payload->Main.checkforChangedFiles(inputs, ~_changedFilesImpl=fakeChangedFiles),
      skipLabel,
    )
  })

  t->test("prerequisite pattern does not match", async t => {
    let preReqPattern = "DirZ/Z"
    let inputs = {...inputs, preReqPattern}

    t->okContains(
      await payload->Main.checkforChangedFiles(inputs, ~_changedFilesImpl=fakeChangedFiles),
      preReqPattern,
    )
  })

  t->test("a file matches", async t => {
    let filePattern = "Dir3/C"
    let inputs = {...inputs, filePattern}

    t->okContains(
      await payload->Main.checkforChangedFiles(inputs, ~_changedFilesImpl=fakeChangedFiles),
      filePattern,
    )
  })

  t->test("failure", async t => {
    let errorMessage = inputs->Main.formatFailureMessage

    t->resultError(
      await payload->Main.checkforChangedFiles(inputs, ~_changedFilesImpl=fakeChangedFiles),
      (t, n) => t->equal(errorMessage, n),
    )
  })
})
