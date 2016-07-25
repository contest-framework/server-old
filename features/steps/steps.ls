require! {
  'chai' : {expect}
  'chalk' : {strip-color}
  'dim-console'
  'fs'
  'lowercase-keys'
  'observable-process' : ObservableProcess
  'path'
  'wait' : {wait}
}


module.exports = ->

  @Given /^a file "([^"]*)" with the content:$/ (file-name, content) ->
    fs.write-file-sync path.join('tmp', file-name), content


  @Given /^a mapper "([^"]*)" with content:$/ (file-name, content) ->
    fs.write-file-sync path.join('tmp', file-name), content



  @When /^starting tertestrial$/ (done) ->
    args =
      console: off
      cwd: 'tmp'
    if @verbose
      args.console = dim-console.console
    @process = new ObservableProcess '../bin/tertestrial', args
      ..wait 'running', done
      ..on 'ended', -> done!


  @When /^sending the command:$/ (table) ->
    command-data = table.hashes![0] |> lowercase-keys |> JSON.stringify
    fs.append-file-sync 'tmp/tertestrial.tmp', command-data


  @Then /^I see "([^"]*)"$/ (expected-text, done) ->
    @process.wait expected-text, done
