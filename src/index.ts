import * as core from "@actions/core";
import * as github from "@actions/github";

import * as gh from "./gh";
import * as matching from "./matching";

function repr(str: string): string {
  return JSON.stringify(str);
}

async function run(): Promise<void> {
  try {
    const payload = gh.pullRequestPayload();
    if (payload === undefined) {
      core.info(
        `${repr(
          github.context.eventName
        )} is not a pull request event; skipping`
      );
      return;
    }

    const skipLabel = core.getInput("skip-label");
    const prLabels = gh.pullRequestLabels(payload);
    if (matching.hasLabelMatch(prLabels, skipLabel)) {
      core.info(`the skip label ${repr(skipLabel)} is set`);
      return;
    }

    const filePaths = await gh.changedFiles(payload);
    const prereqPattern =
      core.getInput("prereq-pattern") || matching.defaultPrereqPattern;
    if (!matching.anyFileMatches(filePaths, prereqPattern)) {
      core.info(
        `prerequisite ${repr(prereqPattern)} did not match any changed files`
      );
      return;
    }

    const filePattern = core.getInput("file-pattern", { required: true });
    if (matching.anyFileMatches(filePaths, filePattern)) {
      core.info(`${repr(filePattern)} matched the changed files`);
      return;
    }

    core.setFailed(
      `prerequisite ${repr(prereqPattern)} matched, but ${repr(
        filePattern
      )} did NOT match any changed files`
    );
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
