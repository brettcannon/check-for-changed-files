import * as core from "@actions/core";

import * as gh from "./gh";
import * as matching from "./matching";

async function run(): Promise<void> {
  try {
    const payload = gh.pullRequestEvent();
    if (payload === undefined) {
      return;
    }
    const filePaths = await gh.changedFiles(payload);
    const requiredGlob = core.getInput("file-glob", { required: true });
    if (!matching.match(filePaths, requiredGlob)) {
      core.setFailed(
        `glob pattern ${requiredGlob} did not match any changed files`
      );
    }
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
