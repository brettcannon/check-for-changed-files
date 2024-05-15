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

// noSkipLabelMatch
// pathsMatchPrereqPattern
// pathsMatchFilePattern
