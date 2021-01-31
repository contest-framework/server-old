require! {
  chalk : {bold, green, red}
  child_process
  events : EventEmitter
  fs
  'prelude-ls': {compact, last}
  wait : {wait}
}


# Creates a named pipe and listens on it for commands coming from the text editor.
#
# Call 'listen' to bring it online.
# Emits a 'command-received' event when it receives a new command
class PipeListener extends EventEmitter

  (@pipe-path) ->
    # indicates whether the process has completely started up yet,
    # or we abort in the middle of the startup process
    @started = no


  cleanup: ->
    | !@started  =>  return
    @killed = yes
    @listener?.kill!
    @delete-named-pipe!


  create-named-pipe: ->
    child_process.exec-sync "mkfifo #{@pipe-path}"


  delete-named-pipe: ->
    try
      fs.unlink-sync @pipe-path


  empty-named-pipe: (done) ->
    | !@exists-named-pipe!  =>  return done!

    done-called = no
    exit = ->
      | done-called  =>  return
      done-called := yes
      done!
    child_process.exec "cat #{@pipe-path}", exit
    wait 0, exit


  exists-named-pipe: ->
    try
      fs.stat-sync @pipe-path
      yes
    catch
      no


  listen: (done) ->
    @reset-named-pipe ~>
      @create-named-pipe!
      @open-read-stream!
      @started = yes
      done!


  open-read-stream: ->
    # Node has seriously issues with named pipes.
    # When reading from one, it is impossible to terminate Node manually
    # using process.exit.
    # Hence we do the pipe reading in a subprocess here.
    @listener = child_process.exec "cat #{@pipe-path}", (err, stdout, stderr) ~>
      | @killed  =>  return
      | err      =>  return @emit 'error', err
      commandString = stdout.split('\n') |> compact |> last
      try
        command = JSON.parse commandString
      catch error
        @emit 'command-parse-error', """
          Invalid command: #{stdout}
          #{error}
          """
        @open-read-stream!
        return
      @emit 'command-received', command
      @open-read-stream!


  reset-named-pipe: (done) ->
    | !@exists-named-pipe!  =>  return done!
    @empty-named-pipe ~>
      @delete-named-pipe!
      done!



module.exports = PipeListener
