import * as core from "@actions/core";

import * as gh from "./gh";
import * as matching from "./matching";

async function run(): Promise<void> {
  try {
    const payload = gh.pullRequestPayload();
    if (payload === undefined) {
      return;
    }

    const skipLabel = core.getInput("skip-label");
    const prLabels = gh.pullRequestLabels(payload);
    if (matching.hasLabelMatch(prLabels, skipLabel)) {
      return;
    }

    const filePaths = await gh.changedFiles(payload);
    const filePattern = core.getInput("file-pattern", { required: true });
    if (!matching.hasFileMatch(filePaths, filePattern)) {
      core.setFailed(
        `the glob pattern '${filePattern}' did not match any changed files`
      );
    }
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
