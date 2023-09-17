import { spawn as spawnCallback } from "cross-spawn";

export function runElmCodegenInstall() {
  return new Promise(async (resolve, reject) => {
    const subprocess = spawnCallback(`${process.cwd()}/node_modules/.bin/elm-codegen`, ["install"], {
      // ignore stdout
      // stdio: ["inherit", "ignore", "inherit"],
      //       cwd: cwd,
    });
    //     if (await fsHelpers.fileExists(outputPath)) {
    //       await fsPromises.unlink(outputPath, {
    //         force: true /* ignore errors if file doesn't exist */,
    //       });
    //     }
    let commandOutput = "";

    subprocess.stderr.on("data", function (data) {
      commandOutput += data;
    });
    subprocess.stdout.on("data", function (data) {
      commandOutput += data;
    });
    subprocess.on("error", function (err) {
      // If there is no entry point found, the syscall will fail but no output will be
      // captured from the target process.
      if (err && err.code === "ENOENT") {
        reject("I could not find elm-codegen. It should be installed as a local dependency to the project using elm-pages. Try running `npm install`")
      } else {
        reject(commandOutput);
      }
    });

    subprocess.on("close", async (code) => {
      if (code == 0) {
        resolve();
      } else {
        reject(commandOutput);
      }
    });
  });
}
