require! {
  './helpers/error-message' : {abort}
  './helpers/file-type'
  'fs'
  'object-depth' : object-depth
  'path'
  'prelude-ls' : {capitalize}
  'remove-value'
  'require-yaml'
}


# Represents the Tertestrial config file
#
# Config files can be written in a variety of languages
# like JavaScript, CoffeeScript, LiveScript, etc
class ConfigFile

  (@config-path) ->
    | !@exists!  =>  abort 'cannot find configuration file'
    @actions = @content!.actions |> @_standardize-actions
    @_convert-regex @actions


  exists: ->
    try
      fs.stat-sync @config-path


  content: ->
    require @config-path


  _convert-regex: (action-sets) !->
    for action-set in action-sets
      for actionset-name, actions of action-set
        for action in actions
          for key, value of action.match
            action.match[key] = new RegExp value


  _load-internal-action: (filename) ->
    require path.join(__dirname, '..', 'actions', "#{filename}.yml")


  _standardize-actions: (actions) ->
    type = typeof! actions
    depth = object-depth actions
    switch
      | type is 'String'                 =>  @_load-internal-action(actions).actions |> @_standardize-actions
      | type is 'Array' and depth is 3   =>  [default: actions]
      | type is 'Array' and depth is 5   =>  actions
      | _                                =>  abort "unknown action type: #{actions}"



module.exports = ConfigFile
