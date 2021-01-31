import * as path from "path"
import { promises as fs } from "fs"
import * as workspace from "./workspace"
import { UserError } from "./user_error"

const PIPE_FILENAME = ".tertestrial.tmp"

export async function send(text: string) {
  // get pipe file path
  const wsRoot = workspace.root()
  if (!wsRoot) {
    throw new UserError("No workspace found")
  }
  const pipePath = path.join(wsRoot, PIPE_FILENAME)
  // ensure pipe exists
  let stat
  try {
    stat = await fs.stat(pipePath)
  } catch (e) {
    if (e.code === "ENOENT") {
      throw new UserError("Please start the Tertestrial server first")
    } else {
      throw new UserError(`Cannot read pipe: ${e}`)
    }
  }
  // ensure is pipe
  if (!stat.isFIFO()) {
    throw new UserError(`The file ${pipePath} exists but is not a FIFO pipe.`)
  }
  // write to pipe
  await fs.appendFile(pipePath, text, {
    flag: "a",
    encoding: "utf8",
  })
}
