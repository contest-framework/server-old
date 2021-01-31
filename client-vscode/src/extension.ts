import * as vscode from "vscode"
import * as pipe from "./pipe"
import * as notification from "./notification"
import * as workspace from "./workspace"
import * as path from "path"

export function activate(context: vscode.ExtensionContext) {
  context.subscriptions.push(vscode.commands.registerCommand("tertestrial-vscode.testAll", testAll))
  context.subscriptions.push(vscode.commands.registerCommand("tertestrial-vscode.testFile", testFile))
}

async function testAll() {
  if (await pipe.send("{}")) {
    notification.display("testing all files")
  }
}

async function testFile() {
  const wsRoot = workspace.root()
  if (!wsRoot) {
    return
  }
  const currentEditor = vscode.window.activeTextEditor
  if (!currentEditor) {
    vscode.window.showErrorMessage("no window open")
    return
  }
  const fullPath = currentEditor.document.fileName
  const relPath = path.relative(wsRoot, fullPath)
  if (await pipe.send(`{"filename": "${relPath}"}`)) {
    notification.display(`testing file ${relPath}`)
  }
}
