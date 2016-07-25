require! {
  'child_process'
  'events' : EventEmitter
  'fs'
}


# Creates a named pipe and listens on it for commands coming from the text editor.
#
# Emits a 'command-received' event when it receives a new command
class PipeListener extends EventEmitter

  ->
    @reset-named-pipe!
    @open-read-stream!


  create-named-pipe: ->
    child_process.exec-sync 'mkfifo tertestrial.tmp'


  delete-named-pipe: ->
    try
      fs.unlink-sync 'tertestrial.tmp'


  # Called when a new command is received from the pipe
  on-stream-data: (command) ~>
    @emit 'command-received', JSON.parse command


  # Called when the read stream from the pipe accidentally ends
  #
  # This shouldn't happen, but does on OS X.
  on-stream-end: ~>
    console.log 'read stream ended, restarting'
    @open-read-stream!


  open-read-stream: ->
    @read-stream = fs.create-read-stream 'tertestrial.tmp', auto-close: no, encoding: 'utf8'
      ..on 'data', @on-stream-data
      ..on 'end', @on-stream-end


  reset-named-pipe: ->
    @delete-named-pipe!
    @create-named-pipe!



module.exports = PipeListener
