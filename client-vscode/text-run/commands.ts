import * as tr from "text-runner"
import * as assertNoDiff from "assert-no-diff"

export function commands(action: tr.actions.Args) {
  const documented = documentedCommands(action.region)
  const exported = exportedCommands()
  assertNoDiff.json(documented, exported)
}

function exportedCommands() {
  const config = require("../package.json")
  const result = []
  const commandRE = /^tertestrial-vscode\./
  const titleRE = /^Tertestrial: /
  for (const command of config.contributes.commands) {
    result.push(`${command.command.replace(commandRE, "")}: ${command.title.replace(titleRE, "")}`)
  }
  return result
}

function documentedCommands(nodes: tr.ast.NodeList) {
  const result = []
  for (const node of nodes.nodesOfTypes("tr_open")) {
    const row = nodes.nodesFor(node)
    const cells = row.nodesOfTypes("td_open")
    if (cells.length === 0) {
      continue
    }
    if (cells.length !== 2) {
      throw new Error(`Row with unexpected length: ${cells}`)
    }
    const command = row.nodesFor(cells[0]).text()
    const desc = row.nodesFor(cells[1]).text()
    result.push(`${command}: ${desc}`)
  }
  return result
}
