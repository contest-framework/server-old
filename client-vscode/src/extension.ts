import * as vscode from "vscode"
import * as pipe from "./pipe"
import * as notification from "./notification"
import * as workspace from "./workspace"
import { UserError } from "./user_error"

export function activate(context: vscode.ExtensionContext) {
  context.subscriptions.push(
    vscode.commands.registerCommand("tertestrial-vscode.testAll", runSafe(testAll)),
    vscode.commands.registerCommand("tertestrial-vscode.testFile", runSafe(testFile)),
    vscode.commands.registerCommand("tertestrial-vscode.testFunction", runSafe(testFunction)),
    vscode.commands.registerCommand("tertestrial-vscode.repeatTest", runSafe(repeatTest)),
    vscode.commands.registerCommand("tertestrial-vscode.stopTest", runSafe(stopTest)),
    vscode.commands.registerCommand("tertestrial-vscode.autoTest", switchAutoTest),
    vscode.workspace.onDidSaveTextDocument(documentSaved)
  )
}

async function testAll() {
  notification.display("testing all files")
  await pipe.send(`{ "command": "testAll" }`)
}

async function testFile() {
  const relPath = workspace.currentFile()
  notification.display(`testing file ${relPath}`)
  await pipe.send(`{ "command": "testFile", "file": "${relPath}" }`)
}

async function testFunction() {
  const relPath = workspace.currentFile()
  const line = workspace.currentLine() + 1
  notification.display(`testing function at ${relPath}:${line}`)
  await pipe.send(`{ "command": "testFunction", "file": "${relPath}", "line": ${line} }`)
}

async function repeatTest() {
  notification.display("repeating the last test")
  await pipe.send(`{ "command": "repeatTest" }`)
}

async function stopTest() {
  notification.display("stopping the current test")
  await pipe.send(`{ "command": "stopTest" }`)
}

function runSafe(f: () => Promise<void>): () => Promise<void> {
  const runAndCatch = async function (f: () => Promise<void>) {
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
  return runAndCatch.bind(null, f)
}

/** indicates whether auto-repeating is enabled on file save */
let autoTest = false

function switchAutoTest() {
  autoTest = !autoTest
  if (autoTest) {
    notification.display("AutoTest ON")
  } else {
    notification.display("AutoTest OFF")
  }
}

function documentSaved() {
  if (autoTest) {
    runSafe(repeatTest)()
  }
}
