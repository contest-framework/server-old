require! {
  './helpers/error-message' : {abort}
  './helpers/file-type'
  'fs'
  'js-yaml' : yaml
  'object-depth' : object-depth
  'path'
  'prelude-ls' : {capitalize}
  'remove-value'
}


# Represents the Tertestrial config file
#
# Config files can be written in a variety of languages
# like JavaScript, CoffeeScript, LiveScript, etc
class ConfigFile

  ->
    | !@exists!  =>  abort 'cannot find configuration file'
    config = yaml.safe-load fs.read-file-sync('tertestrial.yml', 'utf8')
    @actions = config.actions
      |> @_standardize-actions
      |> @_convert-regex


  exists: ->
    try
      fs.stat-sync 'tertestrial.yml'


  _convert-regex: (actions) ->
    switch typeof! actions

      case 'Array'
        for action in actions
          @_convert-regex(action)

      case 'Object'
        for key, value of actions
          if key is 'command' then continue
          if typeof! value is 'String'
            actions[key] = new RegExp value
          else
            actions[key] = @_convert-regex value

      default abort "unknown action key: #{actions}"
    actions


  _load-internal-action: (filename) ->
    path.join __dirname, '..', 'actions', "#{filename}.yml"
      |> fs.read-file-sync _, 'utf8'
      |> yaml.safe-load


  _standardize-actions: (actions) ->
    type = typeof! actions
    depth = object-depth actions
    switch
      | type is 'String'                 =>  @_load-internal-action(actions).actions |> @_standardize-actions
      | type is 'Array' and depth is 2   =>  [default: actions]
      | type is 'Array' and depth is 4   =>  actions
      | _                                =>  abort "unknown action type: #{actions}"



module.exports = ConfigFile
