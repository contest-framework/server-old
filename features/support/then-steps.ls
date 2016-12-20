require! {
  '../../package.json' : pkg
  'chai' : {expect}
  'request'
  'wait' : {wait, wait-until}
  'wait-until' : wait-until-async
}


module.exports = ->

  @Then /^I see "([^"]*)"$/ (expected-text, done) ->
    @process.wait expected-text, (err) ~>
      @process.reset-output-streams!
      done err


  @Then /^I see:$/, timeout: 3000, (expected-text, done) ->
    if @process
      @process.wait expected-text, (err) ~>
        @process.reset-output-streams!
        done err
    else
      expect(@stdout).to.contain expected-text
      done()


  @Then /^I see the version$/ ->
    expect(@stdout).to.contain pkg.version


  @Then /^it creates a file "([^"]*)"$/ (filename) ->
    @file-exists filename


  @Then /^the initial process is still running$/, ->
    expect(@processes-to-kill[0].ended).to.be.false


  @Then /^the long-running test is (no longer )?running$/ (!expect-running, done) ->
    checker = (cb) ->
      request 'http://localhost:3000', (err) ->
        if expect-running
          cb err
        else
          cb !err

    wait-until-async!.condition checker
                     .interval 10
                     .times 100
                     .done -> done!

  @Then /^the process ends$/ (done) ->
    wait-until (~> @process.ended), done


  @Then /^the process is still running$/ (done) ->
    # Note: if the process doesn't crash within 100ms, we consider it remains running
    wait 100, ~>
      expect(@process.ended).to.be.false
      done!
