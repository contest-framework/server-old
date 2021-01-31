import * as vscode from "vscode"
import * as path from "path"
import { promises as fs } from "fs"

const PIPE_FILENAME = ".tertestrial.tmp"

export async function send(text: string): Promise<boolean> {
  // get workspace path
  const wsFolders = vscode.workspace.workspaceFolders
  if (!wsFolders || wsFolders?.length === 0) {
    vscode.window.showErrorMessage("No workspace folders open")
    return false
  }
  // get pipe path
  const pipePath = path.join(wsFolders[0].uri.fsPath, PIPE_FILENAME)
  // ensure pipe exists
  let stat
  try {
    stat = await fs.stat(pipePath)
  } catch (e) {
    if (e.code === "ENOENT") {
      vscode.window.showErrorMessage("Please start the Tertestrial server first")
    } else {
      vscode.window.showErrorMessage(`Cannot read pipe: ${e}`)
    }
    return false
  }
  // ensure is pipe
  if (!stat.isFIFO()) {
    vscode.window.showErrorMessage(`The file ${pipePath} exists but is not a FIFO pipe.`)
    return false
  }
  // write to pipe
  await fs.appendFile(pipePath, text, {
    flag: "a",
    encoding: "utf8",
  })
  return true
}
