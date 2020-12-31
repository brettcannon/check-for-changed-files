import * as core from "@actions/core";
import * as github from "@actions/github";

import * as gh from "./gh";
import * as matching from "./matching";

async function run(): Promise<void> {
  try {
    const payload = gh.pullRequestPayload();
    if (payload === undefined) {
      core.info(
        `the event '${github.context.eventName}' is not for a pull request; skipping`
      );
      return;
    }

    const skipLabel = core.getInput("skip-label");
    const prLabels = gh.pullRequestLabels(payload);
    if (matching.hasLabelMatch(prLabels, skipLabel)) {
      core.info(`the skip label '${skipLabel}' matched`);
      return;
    }

    const filePaths = await gh.changedFiles(payload);
    const prereqPattern =
      core.getInput("prereq-pattern") || matching.defaultPrereqPattern;
    if (!matching.anyFileMatches(filePaths, prereqPattern)) {
      core.info(
        `prerequisite glob pattern '${prereqPattern}' did not match any changed files`
      );
      return;
    }

    const filePattern = core.getInput("file-pattern", { required: true });
    if (!matching.anyFileMatches(filePaths, filePattern)) {
      core.setFailed(
        `the glob pattern '${filePattern}' did not match any changed files`
      );
      return;
    }

    core.info(
      `the glob pattern '${filePattern}' matched one of the changed files`
    );
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
