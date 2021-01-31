import * as vscode from "vscode"
import * as pipe from "./pipe"
import * as notification from "./notification"

export function activate(context: vscode.ExtensionContext) {
  context.subscriptions.push(vscode.commands.registerCommand("tertestrial-vscode.runAll", runAll))
}

async function runAll() {
  if (await pipe.send("{}")) {
    notification.display("Tertestrial: Running all files")
  }
}
