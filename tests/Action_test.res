@module("yaml") external yamlParse: string => 'action = "parse"

open NodeJs
open Zora

zora("action.yml", async t => {
  let actionYAMLPath = Path.join([Path.dirname(__FILE__)->Path.dirname, "action.yml"])
  let actionYAMLFile = await Fs.open_(actionYAMLPath, Fs.Flag.read)
  let actionYAMLBuffer = await Fs.FileHandle.readFile(actionYAMLFile)
  let utf8Decoder = StringEncoding.utf8->StringDecoder.make
  let actionYAMLContents = utf8Decoder->StringDecoder.writeEnd(actionYAMLBuffer)
  let actionYAML = actionYAMLContents->yamlParse
  await actionYAMLFile->Fs.FileHandle.close

  t->test("prereq-pattern default", async t => {
    let prereqPattern = actionYAML["inputs"]["prereq-pattern"]["default"]
    let filePaths = [TestUtils.randomString()]

    t->ok(
      Matching.anyFileMatches(filePaths, prereqPattern),
      "should be true with the default prereq-pattern and any file path",
    )
  })

  t->test("skip-label default", async t => {
    let skipLabelDefault = actionYAML["inputs"]["skip-label"]["default"]

    t->equal("", skipLabelDefault, "should be the empty string")
  })

  t->test("failure-message default", async t => {
    let template = actionYAML["inputs"]["failure-message"]["default"]
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
  })

  t->test("inputs are required or defaults", async t => {
    let inputNames = actionYAML["inputs"]->Object.keysToArray

    inputNames->Array.forEach(
      inputName => {
        let inputDetails = actionYAML["inputs"]->Object.get(inputName)

        switch inputDetails {
        | None => t->fail("Should be impossible")
        | Some(inputDetails) =>
          if !inputDetails["required"] {
            t->ok(inputDetails["default"]->Option.isSome, `"${inputName}" should have a default`)
          }
        }
      },
    )
  })
})
