require! {
  'chai' : {expect}
  'path'
  'wait' : {wait}
}


module.exports = ->


  @When /^entering '\[ENTER\]'$/ ->
    @process.stdin.write "\n"


  @When /^I hit the Enter key$/ ->
    @process.stdin.write "\n"


  @When /^trying to start tertestrial$/ (done) ->
    @start-process 'bin/tertestrial', (err) ->
      expect(err).to.exist
      done!


  @When /^running 'tertestrial ([^']*)'$/ (args) ->
    @stdout = @run-process path.join(process.cwd!, "bin/tertestrial #{args}")


  @When /^starting 'tertestrial setup'$/ ->
    @start-process 'bin/tertestrial setup'


  @When /^sending the command:$/ (command, done) ->
    @send-command command, done


  @When /^sending filename "([^"]*)" and line "([^"]*)"$/ (filename, line, done) ->
    data = {filename}
    data.line = line if line
    @send-command JSON.stringify(data), done


  @When /^sending the filename as the absolute path of "([^"]*)"$/ (filename, done) ->
    data = filename: path.resolve(@root-dir, filename)
    @send-command JSON.stringify(data), done


  @When /^updating the configuration to:$/ (configuration) ->
    # wait a bit here to make sure the server is fully running and settled in
    # before expecting it to respond properly to file changes
    wait 100, ~>
      @create-file 'tertestrial.yml', configuration
