require! {
  'chalk' : {bold, cyan, red}
  './helpers/error-message' : {abort, error}
  './helpers/file-type'
  './helpers/reset-terminal'
  'observable-process' : ObservableProcess
  './helpers/template'
}


# Runs commands sent from the editor
class CommandRunner

  (@config) ->

    # the currently activated mapping number
    @current-mapping = 1

    # the last test command that was sent from the editor
    @current-command = ''


  run-command: (command) ~>
    reset-terminal!
    switch command.operation

      case 'setMapping'
        @set-mapping command

      case 'repeatLastTest'
        if @current-command?.length is 0 then return error "No previous test run"
        unless mapper = @get-mapper @current-command then abort "cannot find a mapper for ", @current-command
        @run-test template(mapper, @current-command)

      default
        unless mapper = @get-mapper command
          abort "cannot find a mapper for ", command
        @current-command = command
        @run-test template(mapper, command)


  get-mapper: ({operation, filename}) ~>
    unless mapping = @config.mappings[@current-mapping]
      abort "mapping ##{@current-mapping} not found"

    mapping = [value for _, value of mapping][0]

    type = file-type filename
    unless type-mapping = mapping[type]
      abort "no mapping for file type #{cyan type}"

    unless mapper = type-mapping[operation]
      abort "no mapper for operation #{cyan operation} on file type #{cyan type}"

    mapper


  run-test: (command) ->
    console.log bold "#{command}\n"
    new ObservableProcess ['sh', '-c', command]


  set-mapping: ({mapping}) ->
    unless new-mapping = @config.mappings[mapping]
      return error "mapping #{cyan mapping} does not exist"
    console.log "Activating mapping #{cyan Object.keys(new-mapping)[0]}"
    @current-mapping = mapping


module.exports = CommandRunner
