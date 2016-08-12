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
    @actions = @content!.actions |> @_standardize-actions
    @_convert-regex @actions


  exists: ->
    try
      fs.stat-sync 'tertestrial.yml'


  content: ->
    yaml.safe-load fs.read-file-sync('tertestrial.yml', 'utf8')


  _convert-regex: (action-sets) !->
    for action-set in action-sets
      for actionset-name, actions of action-set
        for action in actions
          for key, value of action.match
            action.match[key] = new RegExp value


  _load-internal-action: (filename) ->
    path.join __dirname, '..', 'actions', "#{filename}.yml"
      |> fs.read-file-sync _, 'utf8'
      |> yaml.safe-load


  _standardize-actions: (actions) ->
    type = typeof! actions
    depth = object-depth actions
    switch
      | type is 'String'                 =>  @_load-internal-action(actions).actions |> @_standardize-actions
      | type is 'Array' and depth is 3   =>  [default: actions]
      | type is 'Array' and depth is 5   =>  actions
      | _                                =>  abort "unknown action type: #{actions}"



module.exports = ConfigFile
