import * as vscode from "vscode"
import * as path from "path"
import { promises as fs } from "fs"
import * as workspace from "./workspace"

const PIPE_FILENAME = ".tertestrial.tmp"

export async function send(text: string): Promise<boolean> {
  // get pipe file path
  const wsRoot = workspace.root()
  if (!wsRoot) {
    return false
  }
  const pipePath = path.join(wsRoot, PIPE_FILENAME)
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
