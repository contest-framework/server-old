# Tertestrial Protocol

This page defines the wire protocol for communication between Tertestrial
clients and servers.

Tertestrial communication happens through a FIFO pipe named `.tertestrial.tmp`,
located in the root directory of the workspace. The Tertestrial server creates
and removes the pipe to talk to it. Once a server runs, one or more Tertestrial
clients can write Tertestrial commands into the pipe. All commands use the
[newline-delimited JSON](http://ndjson.org) format.

### Test commands

- run all tests: `{}`
- run all tests in a given file: `{ filename: "foo_test.js" }`
- run the test at a given line: `{ filename: "foo_test.js", line: "12" }`
- repeat the last test: `{ "repeatLastTest": true }`
- stop the current test: `{ "stopCurrentTest": true }`

Only one test should be running at a time to avoid interference between
concurrently running tests. A new test must stop the currently running test.

### Action sets

- switch to a different action set: `{ "actionSet": 2 }`
- cycle to the next action set: `{ "cycleActionSet": "next" }`
