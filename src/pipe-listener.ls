require! {
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

  create-named-pipe: ->
    child_process.exec-sync "mkfifo #{@pipe-name}"


  delete-named-pipe: ->
    try
      fs.unlink-sync @pipe-name


  empty-named-pipe: (done) ->
    | !@exists-named-pipe  =>  return done!
    done-called = no
    exit = ->
      | done-called  =>  return
      done-called := yes
      done!
    fs.read-file @pipe-name, exit
    wait 0, exit


  exists-named-pipe: ->
    try
      fs.stat-sync @pipe-name


  listen: (done) ->
    @reset-named-pipe ~>
      @open-read-stream!
      done!


  # Called when a new command is received from the pipe
  on-stream-data: (command) ~>
    @emit 'command-received', JSON.parse command


  # Called when the read stream from the pipe accidentally ends
  #
  # This shouldn't happen, but does on OS X.
  on-stream-end: ~>
    @open-read-stream!


  open-read-stream: ->
    @read-stream = fs.create-read-stream @pipe-name, auto-close: no, encoding: 'utf8'
      ..on 'data', @on-stream-data
      ..on 'end', @on-stream-end


  reset-named-pipe: (done) ->
    @empty-named-pipe ~>
      @delete-named-pipe!
      @create-named-pipe!
      done!



module.exports = PipeListener
