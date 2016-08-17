require! {
  'chalk' : {bold, cyan, red}
  'child_process' : {spawn}
  './helpers/error-message' : {error}
  './helpers/file-type'
  './helpers/fill-template'
  './helpers/reset-terminal'
  'prelude-ls' : {filter, find, sort-by}
  'util'
  'wait' : {wait}
}


# Runs commands sent from the editor
class CommandRunner

  (@config) ->

    # the currently activated action set
    @current-action-set = @config.actions[0]

    @current-action-set-id = 1

    # the last test command that was sent from the editor
    @current-command = ''

    # the currently running test process
    @process = null


  run-command: (command, done) ~>
    reset-terminal!

    if command.action-set
      @set-actionset command.action-set
      if @current-command
        @re-run-last-test done
      else
        done?!
      return

    if command.repeat-last-test
      if @current-command?.length is 0 then return error "No previous test run"
      @re-run-last-test done
      return

    unless template = @_get-template(command) then return error "no matching action found for #{JSON.stringify command}"
    @current-command = command
    @_run-test fill-template(template, command), done


  re-run-last-test: (done) ->
    unless template = @_get-template(@current-command) then return error "cannot find a template for '#{@current-command}'"
    @_run-test fill-template(template, @current-command), done


  set-actionset: (@current-action-set-id) ->
    switch type = typeof! @current-action-set-id

      case 'Number'
        unless new-actionset = @config.actions[@current-action-set-id - 1]
          return error "action set #{cyan @current-action-set-id} does not exist"
        console.log "Activating action set #{cyan Object.keys(new-actionset)[0]}\n"
        @current-action-set = new-actionset

      case 'String'
        new-actionset = @config.actions |> find (action-set) ~> Object.keys(action-set)[0] is @current-action-set-id
        unless new-actionset
          return error "action set #{cyan @current-action-set-id} does not exist"
        console.log "Activating action set #{cyan @current-action-set-id}\n"
        @current-action-set = new-actionset

      default
        error "unsupported action-set id type: #{type}"


  update-config: (@config) ->
    @set-actionset @current-action-set-id
    @re-run-last-test! if @current-command


  # Returns the actions in the current action set
  _current-actions: ->
    for key, value of @current-action-set
      return value



  # Returns the string template for the given command
  _get-template: (command) ~>
    if (matching-actions = @_get-matching-actions command).length is 0
      return null
    matching-actions[*-1].command


  # Returns all actions that match the given command
  _get-matching-actions: (command) ->
    @_current-actions!
      |> filter @_is-match(_, command)
      |> sort-by (.length)


  _action-has-empty-match: (action) ->
    !action.match


  # Returns whether the given action is a match for the given command
  _is-match: (action, command) ->

    # Make sure non-empty commands don't match generic actions
    if @_is-non-empty-command(command) and @_action-has-empty-match(action) then return false

    for key, value of action.match
      if !action.match[key]?.exec command[key] then return false
    true


  _is-non-empty-command: (command) ->
    Object.keys(command).length > 0


  _run-test: (command, done) ->
    @_stop-running-test ~>
      console.log bold "#{command}\n"
      @process = spawn 'sh' ['-c', command], stdio: 'inherit'
      done?!


  _stop-running-test: (done) ->
    | !@process             =>  return done!
    | @process?.exit-code?  =>  return done!
    | @process?.killed      =>  return done!
    @process
      ..on 'exit', -> done!
      ..kill!


module.exports = CommandRunner
