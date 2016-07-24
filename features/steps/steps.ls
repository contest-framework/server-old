require! {
  'chai' : {expect}
  'chalk' : {strip-color}
  'dim-console'
  'observable-process' : ObservableProcess
  'wait' : {wait}
}


module.exports = ->

  @When /^running "([^"]+)"$/ (command) ->
    args = console: off
    if @verbose
      args.console = dim-console.console
    @process = new ObservableProcess ['bash', '-c', command], args


  @Then /^I see "([^"]*)"$/ (expected-text, done) ->
    wait 20, ~>
      expect(@process.full-output! |> strip-color).to.include expected-text
      done!
