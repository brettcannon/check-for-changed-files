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

    t->ok(Matching.anyFileMatches(filePaths, prereqPattern))
  })

  t->test("skip-label default", async t => {
    let skipLabelDefault = actionYAML["inputs"]["skip-label"]["default"]

    t->equal("", skipLabelDefault)
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
      skipLabel: Some(skipLabel),
      token: None,
    }

    let errorMessage = inputs->Main.formatFailureMessage

    t->ok(errorMessage->String.includes(preReqPattern))
    t->ok(errorMessage->String.includes(filePattern))
    t->ok(errorMessage->String.includes(skipLabel))
  })

  t->test("token default", async t => {
    let skipLabelDefault = actionYAML["inputs"]["token"]["default"]

    t->equal("", skipLabelDefault)
  })

  t->test("file-pattern required", async t => {
    t->ok(actionYAML["inputs"]["file-pattern"]["required"])
  })

  t->test("all inputs are required or have defaults", async t => {
    let inputNames = actionYAML["inputs"]->Object.keysToArray

    inputNames->Array.forEach(
      inputName => {
        let inputDetails = actionYAML["inputs"]->Object.get(inputName)

        switch inputDetails {
        | None => t->fail(~msg="Should be impossible")
        | Some(inputDetails) =>
          if !inputDetails["required"] {
            t->ok(
              inputDetails["default"]->Option.isSome,
              ~msg=`"${inputName}" should have a default`,
            )
          }
        }
      },
    )
  })
})
