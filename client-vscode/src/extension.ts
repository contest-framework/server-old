import * as vscode from "vscode"
import { promises as fs } from "fs"

const filePath = ".tertestrial.tmp"

export function activate(context: vscode.ExtensionContext) {
  const runAll = vscode.commands.registerCommand("tertestrial-vscode.runAll", async function () {
    // check if pipe exists
    const uri = vscode.Uri.file("/")
    const folders = vscode.workspace.workspaceFolders
    if (!folders || folders?.length === 0) {
      vscode.window.showErrorMessage("Cannot determine workspaceFolders")
      return
    }
    const wsPath = folders[0].uri.fsPath
    let stat
    try {
      stat = await vscode.workspace.fs.stat(uri)
      // stat = await fs.stat(uri)
    } catch (e) {
      if (e.code === "FileNotFound") {
        vscode.window.showErrorMessage(`Please start the Tertestrial server first: ${e}`)
      } else {
        vscode.window.showErrorMessage(`Error reading pipe: ${e}`)
      }
      return
    }
    if (stat.type) {
      vscode.window.showErrorMessage(`The file ${filePath} must be a FIFO pipe.`)
      return
    }
    await fs.appendFile(filePath, "{}", {
      flag: "a",
      encoding: "utf8",
    })
    vscode.window.setStatusBarMessage("Tertestrial: Running all files")
  })
  context.subscriptions.push(runAll)
}

export function deactivate() {}
