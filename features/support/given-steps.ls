require! {
  'fs'
  'path'
  'wait' : {wait}
}


module.exports = ->

  @Given /^a file "([^"]*)" with the content:$/ (file-name, content) ->
    @create-file file-name, content


  @Given /^Tertestrial is running$/, (done) ->
    @create-file 'tertestrial.yml', 'actions: js-cucumber-mocha'
    @start-process 'bin/tertestrial', done


  @Given /^Tertestrial is running a long\-running test$/ (done) ->
    @root-dir = path.join 'example-applications', 'long-running-tests'
    @start-process 'bin/tertestrial', ~>
      @send-command '{}', done



  @Given /^Tertestrial is running inside the "([^"]*)" example application$/, timeout: 40_000, (app-name, done) ->
    @root-dir = path.join 'example-applications', app-name
    fs.unlink path.join(@root-dir, '.tertestrial.tmp'), ~>
      @run-process 'npm i'
      @start-process 'bin/tertestrial', done


  @Given /^Tertestrial is starting in a directory containing the file "([^"]*)"$/ (filename, done) ->
    @create-file 'tertestrial.yml', 'actions: js-cucumber-mocha'
    @create-file filename, ''
    @start-process 'bin/tertestrial', done


  @Given /^Tertestrial runs with the configuration:$/, timeout: 40_000, (config, done) ->
    @create-file 'tertestrial.yml', config
    @start-process 'bin/tertestrial', done


  @Given /^Tertestrial runs with the configuration file "([^"]*)":$/ (filename, content, done) ->
    @create-file filename, content
    @start-process 'bin/tertestrial', done


  @Given /^Tertestrial had been running a test$/ (done) ->
    @root-dir = path.join 'example-applications', 'js-cucumber-mocha'
    @start-process 'bin/tertestrial', ~>
      @send-command '{"filename": "features/one.feature"}', ~>
        wait 100, done
