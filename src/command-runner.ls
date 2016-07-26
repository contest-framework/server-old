require! {
  'chalk' : {bold, cyan, red}
  './helpers/error-message' : {abort, error}
  './helpers/file-type'
  './helpers/reset-terminal'
  'observable-process' : ObservableProcess
}


# Runs commands sent from the editor
class CommandRunner

  (@config) ->
    @current-mapping = 0


  run-command: (command) ~>
    if command.operation is 'setMapping'
      return @set-mapping command

    if command.operation is 'repeatLastTest'
      return if @current-test?.length > 0
        @run-test @current-test
      else
        error "No previous test run"

    unless mapper = @get-mapper command
      abort "cannot find a mapper for ", command

    @run-test mapper(command)


  get-mapper: ({operation, filename}) ~>
    unless mapping = @config.mappings[@current-mapping]
      abort "mapping ##{@current-mapping} not found"

    type = file-type filename
    unless type-mapping = mapping[type]
      abort "no mapping for file type #{cyan type}"

    unless mapper = type-mapping[operation]
      abort "no mapper for operation #{cyan operation} on file type #{cyan type}"

    mapper


  run-test: (command) ->
    @current-test = command
    reset-terminal!
    console.log bold "#{@current-test}\n"
    new ObservableProcess ['sh', '-c', @current-test]


  set-mapping: ({mapping}) ->
    | !@config.mappings[mapping]  =>  return error "mapping #{cyan mapping} does not exist"
    console.log "\nActivating mapping #{cyan mapping}"
    @current-mapping = mapping


module.exports = CommandRunner