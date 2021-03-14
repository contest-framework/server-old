# Tertestrial Server

<img src="../documentation/icon/icon-color-300.png" width="150" height="124">

This is the Rust implementation of a Tertestrial server.

## Installation

- coming soon: download the correct binary for your platform from the releases
  page
- install the [Tertestrial plugin for your editor](#editor-plugins)
- add `.tertestrial.tmp` to your
  [global gitignore](https://help.github.com/articles/ignoring-files/#create-a-global-gitignore).

## Configuration

Run `tertestrial setup` in the root directory of the code base you wish to use
Tertestrial for to generate an example configuration file (`tertestrial.json`).
It defines which actions Tertestrial should perform in when it receives messages
from Tertestrial clients. Actions look like this:

- the `trigger` block describes the command sent by the Tertestrial client
- the `run` block defines the console command to run

Below is an example configuration file for JavaScript developers who use
[Mocha](https://mochajs.org) for unit testing and
[Cucumber-JS](https://github.com/cucumber/cucumber-js) for end-to-end tests:

**tertestrial.json**

```json
{
  "actions": [
    {
      "trigger": {},
      "run": "make test"
    },
    {
      "trigger": {
        "filename": ".feature$",
        "line": "d+"
      },
      "command": "cucumber-js {{filename}}:{{line}}"
    }
  ]
}
```

### Running

Start Tertestrial by running `tertestrial` in a terminal.

**Pro tip:** if you run tertestrial in the background via `tertestrial &`, you
can see all Tertestrial output and your terminal remains interactive: you can
keep running other commands there as well. Just start typing in the terminal to
see your command prompt. To exit the Tertestrial server in this case, run `fg`
to bring tertestrial back into the foreground, then press **ctrl-c**.

## Editor plugins

- [Vim](https://github.com/kevgo/tertestrial-vim)
- [Emacs](https://github.com/dmh43/emacs-tertestrial)
- [Atom](https://github.com/charlierudolph/tertestrial-atom)

## Development

See the [developer documentation](CONTRIBUTING.md).
