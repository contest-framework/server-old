import * as vscode from "vscode"
import * as util from "util"

const delay = util.promisify(setTimeout)

export async function display(text: string) {
  const notification = vscode.window.setStatusBarMessage(`Tertestrial: ${text}`)
  await delay(1000)
  notification.dispose()
}
