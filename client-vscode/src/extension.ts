import * as vscode from "vscode"
import { promises as fs } from "fs"
import * as path from "path"

const FILE_PATH = ".tertestrial.tmp"

export function activate(context: vscode.ExtensionContext) {
  context.subscriptions.push(vscode.commands.registerCommand("tertestrial-vscode.runAll", runAll))
}

async function runAll() {
  // ensure pipe exists
  const folders = vscode.workspace.workspaceFolders
  if (!folders || folders?.length === 0) {
    vscode.window.showErrorMessage("No workspace folders open")
    return
  }
  const wsPath = folders[0].uri.fsPath
  const pipePath = path.join(wsPath, FILE_PATH)
  let stat
  try {
    stat = await fs.stat(pipePath)
  } catch (e) {
    if (e.code === "ENOENT") {
      vscode.window.showErrorMessage(`Please start the Tertestrial server first: ${e}`)
    } else {
      vscode.window.showErrorMessage(`Error reading pipe: ${e}`)
    }
    return
  }
  if (!stat.isFIFO()) {
    vscode.window.showErrorMessage(`The file ${pipePath} must be a FIFO pipe.`)
    return
  }
  await fs.appendFile(pipePath, "{}", {
    flag: "a",
    encoding: "utf8",
  })
  vscode.window.setStatusBarMessage("Tertestrial: Running all files")
}

export function deactivate() {}
