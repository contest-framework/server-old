import * as vscode from "vscode"
import * as pipe from "./pipe"
import * as util from "util"
const delay = util.promisify(setTimeout)

export function activate(context: vscode.ExtensionContext) {
  context.subscriptions.push(vscode.commands.registerCommand("tertestrial-vscode.runAll", runAll))
}

async function runAll() {
  if (await pipe.send("{}")) {
    const notification = vscode.window.setStatusBarMessage("Tertestrial: Running all files")
    await delay(1000)
    notification.dispose()
  }
}

export function deactivate() {}
