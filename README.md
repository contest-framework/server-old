# Tertestrial Server
> pragmatic test auto-runner

Tertestrial allows you to run unit tests from inside your editor
and see their output in your terminal.
This makes TDD even more efficient.


## Installation

* Copy the file `tertestrial` somewhere into your path and make sure it is executable
* install an editor plugin, for example [tertestrial-vim](https://github.com/kevgo/tertestrial-vim)
* optionally add the file `tertestrial.tmp` to your
  [global gitignore](https://help.github.com/articles/ignoring-files/#create-a-global-gitignore).


## Usage

* start `tertestrial` in the base directory of the code base you are currently developing
* send some commands from the tertestrial editor plugin
* watch your tests run in your terminal

To end the server, press __ctrl-c__ in the terminal.


__Pro tip:__ if you start tertestrial in the background by running `tertestrial &`,
your terminal remains interactive,
i.e. you can keep running other commands there as well.
To exit in this case, run `fg` to bring tertestrial back into the foreground,
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
If you find this software useful, subscribe to Gary's other talks and presentations!


## Development

see our [developer documentation](CONTRIBUTING.md).
