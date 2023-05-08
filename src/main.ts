import * as core from "@actions/core";
import * as github from "@actions/github";
import * as gh from "./gh";
import * as matching from "./matching";

export function repr(str: string): string {
  return JSON.stringify(str);
}

export function formatFailureMessage(
  template: string,
  prereqPattern: string,
  filePattern: string,
  skipLabel: string
): string {
  return template
    .replace("${prereq-pattern}", repr(prereqPattern))
    .replace("${file-pattern}", repr(filePattern))
    .replace("${skip-label}", repr(skipLabel));
}

export async function main(): Promise<void> {
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
        `the prerequisite ${repr(
          prereqPattern
        )} file pattern did not match any changed files of the pull request`
      );
      return;
    }

    const filePattern = core.getInput("file-pattern", { required: true });
    if (matching.anyFileMatches(filePaths, filePattern)) {
      core.info(
        `the ${repr(
          filePattern
        )} file pattern matched the changed files of the pull request`
      );
      return;
    }

    const failureMessage = core.getInput("failure-message");

    core.setFailed(
      formatFailureMessage(
        failureMessage,
        prereqPattern,
        filePattern,
        skipLabel
      )
    );
  } catch (error) {
    core.setFailed(`Action failed with error ${error}`);
  }
}
