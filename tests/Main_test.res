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
      skipLabel,
      token: "",
    }

    let errorMessage = inputs->Main.formatFailureMessage

    t->ok(errorMessage->String.includes(preReqPattern), "should contain the pre-req pattern")
    t->ok(errorMessage->String.includes(filePattern), "should include the file pattern")
    t->ok(errorMessage->String.includes(skipLabel), "should include the skip label")

    t->notOk(
      errorMessage->String.includes("${prereq-pattern}"),
      "should not contain ${prereq-pattern}",
    )
    t->notOk(errorMessage->String.includes("${file-pattern}"), "should not contain ${file-pattern}")

    t->notOk(errorMessage->String.includes("${skip-label}"), "should not contain ${skip-label}")
  })
})

zora("checkForChangedFiles()", async t => {
  let okContains = (t, given: result<string, 'b>, expected: string) =>
    t->resultOk(given, (t, r) =>
      t->ok(r->String.includes(expected), `log message should contain "${expected}"`)
    )

  t->test("not a pull request", async t => {
    let inputs: Action.inputsType = {
      filePattern: "Dir1/B",
      preReqPattern: "**",
      skipLabel: "",
      failureMessage: "${prereq-pattern} ${file-pattern} ${skip-label}",
      token: "",
    }

    t->okContains(await None->Main.checkforChangedFiles(inputs), "pull_request")
  })

  t->skip("skip label set", async t => {
    t->fail("not implemented")
    // let pull_request: GH.prType = {
    //   number: 1234,
    //   labels: [{name: "Label skip"}],
    // }

    // let repository: GH.repoType = {
    //   name: "check-for-changed-files",
    //   owner: {login: "brettcannon"},
    // }

    // let payload: option<GH.prPayloadType> = Some({pull_request, repository})
  })

  t->skip("prerequisite pattern does not match", async t => {
    t->fail("not implemented")
  })

  t->skip("a file matches", async t => {
    t->fail("not implemented")
  })

  t->skip("failure", async t => {
    t->fail("not implemented")
  })
})
