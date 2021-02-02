# Tertestrial Protocol

This page defines the wire protocol for communication between Tertestrial
clients and servers.

Tertestrial communication happens through a FIFO pipe named `.tertestrial.tmp`,
located in the root directory of the workspace. The Tertestrial server creates
and removes the pipe to talk to it. Once a server runs, one or more Tertestrial
clients can write Tertestrial commands into the pipe. All commands use the
[newline-delimited JSON](http://ndjson.org) format.

### Test commands

There are three types of tests:

To have the server run all tests, send this command:

```json
{
  "command": "all"
}
```

To have the server run all tests in a given file, send this command:

```json
{
  "command": "file",
  "file": "<relative file path>"
}
```

To have the server run only the test at a given line, send this command:

```json
{
  "command": "line",
  "file": "<relative file path>",
  "line": <line number starting at 1>
}
```

To have the server repeat the last test, send this command:

```json
{
  "command": "repeatLastTest"
}
```

To have the server stop the currently running test, send this command:

```json
{
  "command": "stopCurrentTest"
}
```

The server runs only one test at a time to avoid interference between
concurrently running tests. If a test is still running, and the server receives
the command to run another test, it stops the currently running test.

### Action sets

- switch to a different action set: `{ "actionSet": 2 }`
- cycle to the next action set: `{ "cycleActionSet": "next" }`
