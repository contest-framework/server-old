require! {
  'chalk' : {bold, cyan, red}
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
      console.log red "Error: cannot find a mapper for ", command
      process.exit 1
    run-string = mapper command
    console.log bold run-string


  get-mapper: ({operation, filename}) ~>
    mapping = @config.mappings[@current-mapping]

    type = file-type filename
    unless type-mapping = mapping[type]
      console.log red "Error: no mapping for file type #{cyan type}"
      process.exit 1

    unless mapper = type-mapping[operation]
      console.log red "Error: no mapper for operation #{cyan operation} on file type #{cyan type}"
      process.exit 1

    mapper


  set-mapping: ({mapping}) ->
    | !@config.mappings[mapping]  =>  return console.log red "Error: mapping #{cyan mapping} does not exist"
    console.log "Activating mapping #{cyan mapping}"
    @current-mapping = mapping


module.exports = CommandRunner
