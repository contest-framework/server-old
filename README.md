# Tertestrial Server

[![CircleCI](https://circleci.com/gh/kevgo/tertestrial-server.svg?style=shield)](https://circleci.com/gh/kevgo/tertestrial-server)
[![Dependency Status](https://david-dm.org/kevgo/tertestrial-server.svg)](https://david-dm.org/kevgo/tertestrial-server)
[![devDependency Status](https://david-dm.org/kevgo/tertestrial-server/dev-status.svg)](https://david-dm.org/kevgo/tertestrial-server#info=devDependencies)

_Runs the currently relevant test from inside your code editor._

It can be configured to work with all test frameworks,
and works with any text editor that has a Tertestrial plugin installed.
Currently there is only a plugin for [Vim](https://github.com/kevgo/tertestrial-vim),
more can be built easily.

Examples:
- open a test file in your editor
- hit a hotkey to run all tests in that file
- hit another hotkey to run only the test under your cursor
- open other code files and edit them
- hit a hotkey to re-run the last test
- hit another hotkey to enable auto-run,
  i.e. automatically re-run the last run test
  each time you save any file in your editor (without having to press further hotkeys)


## Installation

* Copy the file [tertestrial](https://raw.githubusercontent.com/kevgo/tertestrial-server/master/tertestrial)
  somewhere into your path and make sure it is executable.
* install the Tertestrial plugin for your editor, for example [tertestrial-vim](https://github.com/kevgo/tertestrial-vim)
* (optionally) add `tertestrial.tmp` to your
  [global gitignore](https://help.github.com/articles/ignoring-files/#create-a-global-gitignore).


## Usage

Tertestrial requires a configuration file,
so that it knows how your test framework works.
These configuration files are simple [Bash Script](https://www.gnu.org/software/bash)
files.
The config file defines functions that tell Tertestrial
how to perform a particular operation on a particular file type.

What type of operation and file type is requested by the user
is made available in these variables:
<table>
  <tr>
    <th>variable name</th>
    <th>description</th>
    <th>example content</th>
  </tr>
  <tr>
    <td>$operation</td>
    <td>the operation to perform</td>
    <td>
      "test_file" to test the whole file,<br>
      "test_file_line" to test the file at the given line
    </td>
  <tr>
  <tr>
    <td>$filetype</td>
    <td>the type of file you want to test</td>
    <td>"cucumber"</td>
  <tr>
  <tr>
    <td>$filename</td>
    <td>path to the file to test</td>
    <td>"features/foo.feature"</td>
  <tr>
  <tr>
    <td>$line</td>
    <td>
      the current line in the file <br>
      (only provided when you want to test at a line)
    </td>
    <td>"12"</td>
  <tr>
</table>


The name for the functions in the config file has the format
`command_for_<operation>_<filetype>`.
Here is an example Tertestrial config file to run
[Cucumber-JS](https://github.com/cucumber/cucumber-js)
tests:

```bash
#!/usr/bin/env bash

# Provides the command to test a whole Cucumber file
function command_for_test_file_cucumber {
  echo "cucumber-js $filename"
}

# Provides the command to test a Cucumber file at the given line
function command_for_test_file_line_cucumber {
  echo "cucumber-js $filename:$line"
}
```

Save this file under the name `tertestrial-config` into the root directory of your code base.
Then:
* start `tertestrial` in the base directory of your code base
* send some commands using the tertestrial editor plugin
* watch your tests run in your terminal

To end the server, press __ctrl-c__ in the terminal.


__Pro tip:__ if you start tertestrial in the background by running `tertestrial &`,
your terminal remains interactive,
i.e. you can keep running other commands there as well.
Just start typing in the terminal to see your command prompt.
To exit the Tertestrial server in this case,
run `fg` to bring tertestrial back into the foreground,
then press __ctrl-c__.


## How it works

Tertestrial consists of a server (in this repository)
and a number of editor plugins.
The editor plugins send commands to the server
via a pipe named `tertestrial.tmp` in the directory where you start the server
(typically the base directory of the code base you are working on).
Tertestrial removes this pipe when stopping.


## Credits

This software is based on an idea described by Gary Bernhard in his excellent
[Destroy All Software screencasts](https://www.destroyallsoftware.com/screencasts/catalog/running-tests-asynchronously).
If you find this software useful,
subscribe to Gary's talks and presentations
for more of his cool ideas!


## Development

see our [developer documentation](CONTRIBUTING.md).
