require! {
  'chalk' : {bold, cyan, green, red}
  'child_process' : {spawn}
  './helpers/error-message' : {error}
  './helpers/file-type'
  './helpers/fill-template'
  './helpers/reset-terminal'
  'path'
  'prelude-ls' : {filter, find-index, sort-by}
  'util'
}


# Runs commands sent from the editor
class CommandRunner

  (@config) ->

    # the currently activated action set
    @current-action-set = @config.actions[0]

    @current-action-set-index = 0

    # the last test command that was sent from the editor
    @current-command = ''

    # the currently running test process
    @current-process = null


  run-command: (command, done) ~>
    reset-terminal!

    if command.action-set
      @current-action-set-index = @standardize-action-set-index command.action-set
      @set-actionset done
      return

    if command.cycle-action-set
      @current-action-set-index = (@current-action-set-index + 1) % @config.actions.length
      @set-actionset done
      return

    if command.repeat-last-test
      if @current-command?.length is 0 then return error "No previous test run"
      @re-run-last-test done
      return

    if command.filename
      command.filename = path.relative process.cwd(), command.filename

    unless template = @_get-template(command) then return error "no matching action found for #{JSON.stringify command}"
    @current-command = command
    @_run-test fill-template(template, command), done


  re-run-last-test: (done) ->
    unless template = @_get-template(@current-command) then return error "cannot find a template for '#{@current-command}'"
    @_run-test fill-template(template, @current-command), done


  set-actionset: (done) ->
    | !@current-action-set-index? => return
    @current-action-set = @config.actions[@current-action-set-index]
    console.log "Activating action set #{cyan Object.keys(@current-action-set)[0]}\n"
    if @current-command
      @re-run-last-test done
    else
      done?!


  standardize-action-set-index: (action-set-id) ->
    switch type = typeof! action-set-id

      case 'Number'
        if action-set-id < 1 or action-set-id > @config.actions.length
          error "action set #{cyan action-set-id} does not exist"
        else
          action-set-id - 1

      case 'String'
        index = @config.actions |> find-index -> Object.keys(it)[0] is action-set-id
        if index?
          index
        else
          error "action set #{cyan action-set-id} does not exist"

      default
        error "unsupported action-set id type: #{type}"


  update-config: (@config) ->
    @set-actionset @current-action-set-id


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
      @current-process = spawn 'sh' ['-c', command], stdio: 'inherit'
        ..on 'exit', (code) ->
          style = if code is 0 then green else red
          console.log style "\nexit code: #{code}"
      done?!


  _stop-running-test: (done) ->
    | !@current-process             =>  return done!
    | @current-process?.exit-code?  =>  return done!
    | @current-process?.killed      =>  return done!
    @current-process
      ..on 'exit', -> done!
      ..kill!


module.exports = CommandRunner
