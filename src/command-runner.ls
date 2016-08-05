require! {
  'chalk' : {bold, cyan, red}
  'child_process' : {spawn}
  './helpers/error-message' : {abort, error}
  './helpers/file-type'
  './helpers/fill-template'
  './helpers/reset-terminal'
  'prelude-ls' : {filter, sort-by}
}


# Runs commands sent from the editor
class CommandRunner

  (@config) ->

    # the currently activated action set
    @current-action-set-nr = 1

    # the last test command that was sent from the editor
    @current-command = ''


  run-command: (command) ~>
    reset-terminal!

    if command.action-set
      @set-actionset command.action-set
      return

    if command.operation is 'repeatLastTest'
      if @current-command?.length is 0 then return error "No previous test run"
      template = @_get-template(@current-command) or abort "cannot find a template for ", @current-command
      @_run-test fill-template(template, @current-command)
      return

    template = @_get-template(command) or abort "cannot find a template for ", command
    @current-command = command
    @_run-test fill-template(template, command)


  # Returns the actions in the current action set
  _current-actions: ->
    for key, value of @config.actions[@current-action-set-nr - 1]
      return value



  # Returns the string template for the given command
  _get-template: (command) ~>
    matching-actions = @_get-matching-actions command
    if matching-actions.length is 0 then abort "no matching action found for #{JSON.stringify command}"
    matching-actions[*-1].command


  # Returns all actions that match the given command
  _get-matching-actions: (command) ->
    @_current-actions!
      |> filter @_is-match(_, command)
      |> sort-by (.length)


  # Returns whether the given action is a match for the given command
  _is-match: (action, command) ->
    for key, value of action
      continue if key is 'command'
      if !action[key]?.exec command[key] then return false
    true


  _run-test: (command) ->
    console.log bold "#{command}\n"
    spawn 'sh' ['-c', command], stdio: 'inherit'


  set-actionset: (+action-set-nr) ->
    unless new-actionset = @config.actions[action-set-nr - 1]
      return error "action set #{cyan action-set-nr} does not exist"
    console.log "Activating action set #{cyan Object.keys(new-actionset)[0]}"
    @current-action-set-nr = action-set-nr



module.exports = CommandRunner
