require! {
  'chalk' : {bold, cyan, red}
  './helpers/error-message' : {abort, error}
  './helpers/file-type'
}


# Runs commands sent from the editor
class CommandRunner

  (@config) ->
    @current-mapping = 0


  run-command: (command) ~>
    if command.operation is 'setMapping'
      @set-mapping command
      return

    unless mapper = @get-mapper command
      abort "cannot find a mapper for ", command
    run-string = mapper command
    console.log bold run-string


  get-mapper: ({operation, filename}) ~>
    mapping = @config.mappings[@current-mapping]

    type = file-type filename
    unless type-mapping = mapping[type]
      abort "no mapping for file type #{cyan type}"

    unless mapper = type-mapping[operation]
      abort "no mapper for operation #{cyan operation} on file type #{cyan type}"

    mapper


  set-mapping: ({mapping}) ->
    | !@config.mappings[mapping]  =>  return error "mapping #{cyan mapping} does not exist"
    console.log "\nActivating mapping #{cyan mapping}"
    @current-mapping = mapping


module.exports = CommandRunner
