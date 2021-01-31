import * as vscode from "vscode"
import * as path from "path"
import { UserError } from "./user_error"

/** provides the path of the workspace */
export function root(): string {
  const wsFolders = vscode.workspace.workspaceFolders
  if (!wsFolders || wsFolders?.length === 0) {
    throw new UserError("No workspace folder")
  }
  return wsFolders[0].uri.fsPath
}

/** provides the relative path to the currently open file */
export function currentFile(): string {
  return path.relative(root(), currentEditor().document.fileName)
}

export function currentLine(): number {
  const editor = currentEditor()
  // if (editor.selection.isEmpty) {
  return editor.selection.active.line
  // }
}

function currentEditor(): vscode.TextEditor {
  const result = vscode.window.activeTextEditor
  if (!result) {
    throw new UserError("no window open")
  }
  return result
}
