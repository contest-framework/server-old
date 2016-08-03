require! {
  'chalk' : {bold, cyan, red}
  'child_process' : {spawn}
  './helpers/error-message' : {abort, error}
  './helpers/file-type'
  './helpers/reset-terminal'
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
        mapper = @get-mapper(@current-command) or abort "cannot find a mapper for ", @current-command
        @run-test template(mapper, @current-command)

      default
        mapper = @get-mapper(command) or abort "cannot find a mapper for ", command
        @current-command = command
        @run-test template(mapper, command)


  get-mapper: ({operation, filename}) ~>
    mapping = @config.mappings[@current-mapping] or abort "mapping ##{@current-mapping} not found"
    mapping = [value for _, value of mapping][0]
    type = if filename then file-type filename
    if type
      type-mapping = mapping[type] or mapping.default
      if not type-mapping then abort "no mapping for file type #{cyan type}"
    else if mapping.default
      type-mapping = mapping.default
    else abort "no file type or default mapping specified"
    type-mapping[operation] or abort "no mapper for operation #{cyan operation} on file type #{cyan type}"


  run-test: (command) ->
    console.log bold "#{command}\n"
    spawn 'sh' ['-c', command], stdio: 'inherit'


  set-mapping: ({mapping}) ->
    unless new-mapping = @config.mappings[mapping]
      return error "mapping #{cyan mapping} does not exist"
    console.log "Activating mapping #{cyan Object.keys(new-mapping)[0]}"
    @current-mapping = mapping


module.exports = CommandRunner
