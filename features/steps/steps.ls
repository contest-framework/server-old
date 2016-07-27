require! {
  'chai' : {expect}
  'chalk' : {strip-color}
  'child_process'
  'dim-console'
  'fs'
  'observable-process' : ObservableProcess
  'path'
  'wait' : {wait}
}


module.exports = ->

  @Given /^a file "([^"]*)" with the content:$/ (file-name, content) ->
    fs.write-file-sync path.join('tmp', file-name), content


  @Given /^a mapper "([^"]*)" with content:$/ (file-name, content) ->
    fs.write-file-sync path.join('tmp', file-name), content


  @Given /^Tertestrial is running inside the "([^"]*)" example application$/, timeout: 20_000, (app-name, done) ->
    @root-dir = path.join 'example-applications', app-name

    # install npm dependencies
    child_process.exec-sync 'npm i', cwd: @root-dir

    # start Tertestrial
    args =
      console: off
      cwd: @root-dir
    if @verbose
      args.console = dim-console.console
    @process = new ObservableProcess '../../bin/tertestrial', args
      ..wait 'running', done
      ..on 'ended', (exit-code) ~> done "App crashed with code #{exit-code}!\n\n#{@process.full-output!}"


  @When /^entering '\[ENTER\]'$/ ->
    @process.stdin.write "\n"


  @When /^starting tertestrial$/ (done) ->
    @root-dir = 'tmp'
    args =
      console: off
      cwd: @root-dir
    if @verbose
      args.console = dim-console.console
    @process = new ObservableProcess '../bin/tertestrial', args
      ..wait 'running', done
      ..on 'ended', -> done!


  @When /^starting 'tertestrial \-\-setup'$/ ->
    @root-dir = 'tmp'
    args =
      console: off
      cwd: @root-dir
    if @verbose
      args.console = dim-console.console
    @process = new ObservableProcess '../bin/tertestrial --setup', args


  @When /^sending the command:$/ (command, done) ->
    wait 10, ~>
      fs.append-file-sync path.join(@root-dir, 'tertestrial.tmp'), command
      done!


  @When /^sending the operation "([^"]*)" on filename "([^"]*)" and line "([^"]*)"$/ (operation, filename, line, done) ->
    wait 10, ~>
      command-data = {operation, filename, line} |> JSON.stringify
      fs.append-file-sync path.join(@root-dir, 'tertestrial.tmp'), command-data
      done!


  @Then /^I see "([^"]*)"$/ (expected-text, done) ->
    @process.wait expected-text, done


  @Then /^it creates a file "([^"]*)"$/ (filename) ->
    fs.stat-sync path.join(@root-dir, filename)
