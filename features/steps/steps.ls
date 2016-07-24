require! {
  'chai' : {expect}
  'chalk' : {strip-color}
  'dim-console'
  'fs'
  'observable-process' : ObservableProcess
  'path'
  'wait' : {wait}
}


module.exports = ->

  @Given /^a file "([^"]*)" with the content:$/ (file-name, content) ->
    fs.write-file-sync path.join('tmp', file-name), content


  @When /^running "([^"]+)"$/ (command, done) ->
    args =
      console: off
      cwd: 'tmp'
    if @verbose
      args.console = dim-console.console
    @process = new ObservableProcess ['bash', '-c', command], args
    wait 100, done   # give tertestrial some time to boot up


  @When /^sending the command:$/ (table) ->
    command = ["#{key.to-lower-case!}=\"#{value}\"" for key, value of table.hashes![0]].join '; '
    fs.append-file-sync 'tmp/tertestrial.tmp', command


  @Then /^I see "([^"]*)"$/ (expected-text, done) ->
    wait 100, ~>
      expect(@process.full-output! |> strip-color).to.include expected-text
      done!
