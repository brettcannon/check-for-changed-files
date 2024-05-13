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

  t->test("prereq-pattern default", async t => {
    let prereqPattern = actionYAML["inputs"]["prereq-pattern"]["default"]
    let filePaths = [TestUtils.randomString()]

    t->ok(
      Matching.anyFileMatches(filePaths, prereqPattern),
      "should be true with the default prereq-pattern and any file path",
    )
  })

  // TODO
  t->test("failure-message default", async t => {
    let template = actionYAML["inputs"]["failure-message"]["default"]
    let prereqPattern = TestUtils.randomString()
    let filePattern = TestUtils.randomString()
    let skipLabel = TestUtils.randomString()

    let errorMessage = template->Main.formatFailureMessage(~prereqPattern, ~filePattern, ~skipLabel)

    t->ok(errorMessage->String.includes(prereqPattern), "should contain the pre-req pattern")
    t->ok(errorMessage->String.includes(filePattern), "should include the file pattern")
    t->ok(errorMessage->String.includes(skipLabel), "should include the skip label")
  })
})
