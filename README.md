# Tertestrial Server

[![CircleCI](https://circleci.com/gh/kevgo/tertestrial-server.svg?style=shield)](https://circleci.com/gh/kevgo/tertestrial-server)
[![Dependency Status](https://david-dm.org/kevgo/tertestrial-server.svg)](https://david-dm.org/kevgo/tertestrial-server)
[![devDependency Status](https://david-dm.org/kevgo/tertestrial-server/dev-status.svg)](https://david-dm.org/kevgo/tertestrial-server#info=devDependencies)

_Runs the currently relevant test while coding._

Tertestrial runs configurable tasks on files or parts of files.
Tasks are triggered by hotkeys from within your code editor,
or automatically on file save.
An example is running a particular unit test that you want to make green
as part of test-driven development.

[screencast]

Tertestrial works with all test frameworks (see the ones [supported out of the box](mappings))
and any text editor with a [Tertestrial plugin](#editor-plugins).


## Installation

* install [Node.js](https://nodejs.org/en)

* install the Tertestrial server:

  ```
  npm i -g tertestrial
  ```

* install the [Tertestrial plugin for your editor](#editor-plugins)

* add `tertestrial.tmp` to your
  [global gitignore](https://help.github.com/articles/ignoring-files/#create-a-global-gitignore).


## Creating a configuration file

To use Tertestrial with a code base,
run `tertestrial --setup` in the root directory of that code base.
This generates a configuration file
that tells Tertestrial
what to do with the different types of files in your project.

The setup script asks whether you want to use one of the built-in configurations
or make your own.
If you select a built-in configuration,
you are done with the setup and can [start using Tertestrial](#running-tertestrial).

If you want to make your own custom configuration,
the setup script scaffolds a config file for you that you have to finish yourself.
Make it look similar to the example configuration file below,
which is for running unit tests using [Mocha](https://mochajs.org)
and end-to-end tests using [Cucumber-JS](https://github.com/cucumber/cucumber-js):

__tertestrial.yml__
```yml
mappings:
  js:
    testFile: "mocha {{filename}}"
    testLine: "mocha {{filename}} -l {{line}}"
  feature:
    testFile: "cucumber-js {{filename}}"
    testLine: "cucumber-js {{filename}}:{{line}}"
```

In this example,
`js` and `feature` are the filename extensions for which we provide test commands.
`testFile` means the user wants to run all tests in the current file,
`testLine` means to run only the test at the current line of the current file.
The commands to run are specified via
<a href="https://en.wikipedia.org/wiki/Mustache_(template_system)#Examples)">Mustache</a> templates.


### Multiple mapping sets

Tertestrial allows to define several sets of mappings
and switch between them at runtime.
An example is to have one mapping for running end-to-end tests using a real browser
and another to run them using a faster headless browser.

__tertestrial.yml__

```yml
headless-mappings:
  feature:
    testFile: "TEST_PLATFORM=headless cucumber-js {{filename}}"
    testLine: "TEST_PLATFORM=headless cucumber-js {{filename}}:{{line}}"

firefox-mappings:
  feature:
    testFile: "TEST_PLATFORM=firefox cucumber-js {{filename}}"
    testLine: "TEST_PLATFORM=firefox cucumber-js {{filename}}:{{line}}"

mappings:
  - headless-mappings
  - firefox-mappings
```


## Running tertestrial

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
via a named pipe `tertestrial.tmp` in the directory where you start the server
(typically the base directory of the code base you are working on).
Tertestrial removes this pipe when stopping.


## Editor plugins

* [Vim](https://github.com/kevgo/tertestrial-vim)


## Create your own editor plugin

Making your own editor plugin is super easy.
All your plugin has to do is be triggered somehow (ideally via hotkeys)
and write the command to execute as a JSON string into the file `tertestrial.tmp`:

* to test a whole file:

  ```json
  {"operation": "testFile", "filename": "test/foo.rb"}
  ```

* to test just the current line of a file:

  ```json
  {"operation": "testLine", "filename": "test/foo.rb", "line": 12}
  ```

* to repeat the last run test

  ```json
  {"operation": "repeatLastTest"}
  ```

* to switch to a different mapping:

  ```json
  {"operation": "setMapping", "mapping": 2}
  ```


## Credits

This software is based on an idea described by Gary Bernhard in his excellent
[Destroy All Software screencasts](https://www.destroyallsoftware.com/screencasts/catalog/running-tests-asynchronously).
If you find this software useful,
subscribe to Gary's talks and presentations
for more of his cool ideas!


## Development

see our [developer documentation](CONTRIBUTING.md).
