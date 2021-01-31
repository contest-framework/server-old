import * as vscode from "vscode"
import * as pipe from "./pipe"
import * as notification from "./notification"
import * as workspace from "./workspace"
import { UserError } from "./user_error"

export function activate(context: vscode.ExtensionContext) {
  context.subscriptions.push(vscode.commands.registerCommand("tertestrial-vscode.testAll", runSafe(testAll)))
  context.subscriptions.push(vscode.commands.registerCommand("tertestrial-vscode.testFile", runSafe(testFile)))
  context.subscriptions.push(vscode.commands.registerCommand("tertestrial-vscode.testLine", runSafe(testLine)))
}

async function testAll() {
  notification.display("testing all files")
  await pipe.send("{}")
}

async function testFile() {
  const relPath = workspace.currentFile()
  notification.display(`testing file ${relPath}`)
  await pipe.send(`{"filename": "${relPath}"}`)
}

async function testLine() {
  const relPath = workspace.currentFile()
  const line = workspace.currentLine()
  notification.display(`testing file ${relPath}:${line}`)
  await pipe.send(`{"filename": "${relPath}", "line": "${line}"}`)
}

function runSafe(f: () => Promise<void>): () => Promise<void> {
  const result = async function (f: () => Promise<void>) {
    try {
      await f()
    } catch (e) {
      if (e instanceof UserError) {
        vscode.window.showErrorMessage(e.message)
      } else {
        throw e
      }
    }
  }
  return result.bind(null, f)
}
