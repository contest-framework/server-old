require! {
  'chalk' : {bold, green, red}
  'child_process'
  'events' : EventEmitter
  'fs'
  'wait' : {wait}
}


# Creates a named pipe and listens on it for commands coming from the text editor.
#
# Call 'listen' to bring it online.
# Emits a 'command-received' event when it receives a new command
class PipeListener extends EventEmitter

  ->
    @pipe-name = '.tertestrial.tmp'

    # indicates whether the process has completely started up yet,
    # or we abort in the middle of the startup process
    @started = no


  cleanup: ->
    @delete-named-pipe! if @started


  create-named-pipe: ->
    child_process.exec-sync "mkfifo #{@pipe-name}"


  delete-named-pipe: ->
    try
      fs.unlink-sync @pipe-name


  empty-named-pipe: (done) ->
    | !@exists-named-pipe!  =>  return done!

    done-called = no
    exit = ->
      | done-called  =>  return
      done-called := yes
      done!
    child_process.exec 'cat .tertestrial.tmp', exit
    wait 0, exit


  exists-named-pipe: ->
    try
      fs.stat-sync @pipe-name
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
    child_process.exec 'cat .tertestrial.tmp', (err, stdout, stderr) ~>
      | err  =>  return @emit 'error', err
      try
        @emit 'command-received', JSON.parse(stdout)
      catch error
        @emit 'command-parse-error', """
          Invalid command:
            Command: #{stdout}
            #{error}
          """
      @open-read-stream!


  reset-named-pipe: (done) ->
    | !@exists-named-pipe!  =>  return done!
    @empty-named-pipe ~>
      @delete-named-pipe!
      done!



module.exports = PipeListener
