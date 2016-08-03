require! {
  'chai' : {expect}
  'path'
}


module.exports = ->

  @Given /^a file "([^"]*)" with the content:$/ (file-name, content) ->
    @create-file file-name, content


  @Given /^a mapper "([^"]*)" with content:$/ (file-name, content) ->
    @create-file file-name, content


  @Given /^Tertestrial is running inside the "([^"]*)" example application$/, timeout: 20_000, (app-name, done) ->
    @root-dir = path.join 'example-applications', app-name
    @run-process 'npm i'
    @start-process '../../bin/tertestrial', done


  @Given /^Tertestrial runs with the configuration:$/, timeout: 20_000, (config, done) ->
    @root-dir = 'tmp'
    @create-file 'tertestrial.yml', config
    @start-process '../bin/tertestrial', done


  @When /^entering '\[ENTER\]'$/ ->
    @process.stdin.write "\n"


  @When /^trying to start tertestrial$/ (done) ->
    @root-dir = 'tmp'
    @start-process '../bin/tertestrial', (err) ->
      expect(err).to.exist
      done!


  @When /^starting 'tertestrial \-\-setup'$/ ->
    @root-dir = 'tmp'
    @start-process '../bin/tertestrial --setup'


  @When /^sending the command:$/ (command, done) ->
    @send-command command, done


  @When /^sending the operation "([^"]*)" on filename "([^"]*)" and line "([^"]*)"$/ (operation, filename, line, done) ->
    @send-command JSON.stringify({operation, filename, line}), done


  @Then /^I see "([^"]*)"$/ (expected-text, done) ->
    @process.wait expected-text, done


  @Then /^it creates a file "([^"]*)"$/ (filename) ->
    @file-exists filename
