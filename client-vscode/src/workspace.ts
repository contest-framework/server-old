import * as vscode from "vscode"

/** provides the path of the workspace */
export function root(): string | null {
  const wsFolders = vscode.workspace.workspaceFolders
  if (!wsFolders || wsFolders?.length === 0) {
    vscode.window.showErrorMessage("No workspace folders open")
    return null
  }
  return wsFolders[0].uri.fsPath
}
