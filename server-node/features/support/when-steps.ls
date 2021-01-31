require! {
  'chai' : {expect}
  'cucumber': {defineSupportCode}
  'path'
  'wait' : {wait}
}


defineSupportCode ({When}) ->


  When /^entering '\[ENTER\]'$/ ->
    @process.stdin.write "\n"


  When /^I hit the Enter key$/ ->
    @process.stdin.write "\n"


  When /^trying to start tertestrial$/ (done) ->
    @start-process @tertestrial-path, (err) ->
      expect(err).to.exist
      done!


  When /^running 'tertestrial ([^']*)'$/ (args) ->
    @stdout = @run-process "#{@tertestrial-path} #{args}"


  When /^starting 'tertestrial setup'$/ ->
    @start-process "#{@tertestrial-path} setup"


  When /^sending the command:$/ (command, done) ->
    @send-command command, done


  When /^sending filename "([^"]*)" and line "([^"]*)"$/ (filename, line, done) ->
    data = {filename}
    data.line = line if line
    @send-command JSON.stringify(data), done


  When /^sending the filename as the absolute path of "([^"]*)"$/ (filename, done) ->
    data = filename: path.resolve(@root-dir, filename)
    @send-command JSON.stringify(data), done


  When /^updating the configuration to:$/ (configuration) ->
    # wait a bit here to make sure the server is fully running and settled in
    # before expecting it to respond properly to file changes
    wait 100, ~>
      @create-file 'tertestrial.yml', configuration
