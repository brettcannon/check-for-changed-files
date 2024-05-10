open Zora

// TODO pullRequestLabels
// TODO changedFiles

zora("pullRequestPayload()", async t => {
  let prData: GH.prType = {
    number: 1234,
    labels: [],
  }

  let repoData: GH.repoType = {
    name: "check-for-changed-files",
    owner: {login: "brettcannon"},
  }

  let payload: GH.payloadType = {
    "pull_request": Some(prData),
    "repository": Some(repoData),
  }

  t->test("success", async t => {
    let context: GH.contextType = {
      "eventName": #pull_request,
      "payload": Some(payload),
    }

    let prPayload = GH.pullRequestPayload(~context)

    t->optionSome(
      prPayload,
      (t, actual) =>
        t->equal(
          actual,
          {GH.pull_request: prData, repository: repoData},
          "repo and PR data w/o option",
        ),
    )
  })

  t->test("not a PR event", async t => {
    let context: GH.contextType = {
      "eventName": #issues,
      "payload": Some(payload),
    }

    t->optionNone(
      GH.pullRequestPayload(~context),
      "should be None when not a PR event (based on name)",
    )
  })

  t->test("No payload", async t => {
    let context = {
      "eventName": #pull_request,
      "payload": None,
    }

    t->optionNone(GH.pullRequestPayload(~context), "should be None when no payload")
  })

  t->test("No repository data", async t => {
    let payload: GH.payloadType = {
      "pull_request": Some(prData),
      "repository": None,
    }

    let context: GH.contextType = {
      "eventName": #pull_request,
      "payload": Some(payload),
    }

    t->optionNone(GH.pullRequestPayload(~context), "should be None when no repo data")
  })

  t->test("No pull request data", async t => {
    let payload: GH.payloadType = {
      "pull_request": None,
      "repository": Some(repoData),
    }

    let context: GH.contextType = {
      "eventName": #pull_request,
      "payload": Some(payload),
    }

    t->optionNone(
      GH.pullRequestPayload(~context),
      "should be None when not a PR event (based on name)",
    )
  })
})
