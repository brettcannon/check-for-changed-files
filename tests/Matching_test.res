open Zora

zora("hasLabelMatch", async t => {
  t->test("label matches", async t => {
    let labels = ["A", "B", "C"]

    t->ok(labels->Matching.hasLabelMatch("B"))
  })

  t->test("no labels match", async t => {
    let labels = ["A", "B", "C"]

    t->notOk(labels->Matching.hasLabelMatch("D"))
  })
})

zora("anyFileMatches", async t => {
  t->test("single pattern", async t => {
    let filePaths = ["B", "d1/d2/d3/A"]
    let patterns = "*/**/A"
    t->ok(filePaths->Matching.anyFileMatches(patterns))
  })

  t->test("multiple patterns", async t => {
    let filePaths = ["A", "d1/B", "C"]
    let patterns = "D\n*/**/B\nE"
    t->ok(filePaths->Matching.anyFileMatches(patterns))
  })

  t->test("no match", async t => {
    let filePaths = ["A", "B", "C"]
    let patterns = "D"
    t->notOk(filePaths->Matching.anyFileMatches(patterns))
  })

  t->test("paths with a leading dot", async t => {
    let filePaths = ["a/.d/b"]
    let patterns = "a/**/b"
    t->ok(filePaths->Matching.anyFileMatches(patterns))
  })
})
