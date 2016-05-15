# Tertestrial Server
> TDD at your fingertips

Tertestrial allows you to run unit tests from inside your editor
and see their output in your terminal.
This makes TDD even more efficient.


## Installation

* Copy the file `tertestrial` somewhere into your path and make sure it is executable
* install an editor plugin, for example [tertestrial-vim]()
* add the file `tertestrial` to your
  [global gitignore](https://help.github.com/articles/ignoring-files/#create-a-global-gitignore).


## Usage

* start `tertestrial` in the base directory of the code base you are currently developing
* send some commands from the tertestrial editor plugin
* watch your tests run in your terminal

__Pro tip:__ if you start `tertestrial` in the background (`tertestrial &`),
your terminal remains interactive,
and you can keep running other commands there as well.


## How it works

Tertestrial consists of a server (in this repository)
and a number of editor plugins.

The editor plugins send commands to the server
via a pipe named `tertestrial` in the directory where you start the server
(typically the base directory of the code base you are working on).
Don't check this file into Git.
