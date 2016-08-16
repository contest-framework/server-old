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
    child_process.exec 'cat .tertestrial.tmp', exit
    wait 0, exit


  exists-named-pipe: ->
    try
      fs.stat-sync @pipe-name


  listen: (done) ->
    @reset-named-pipe ~>
      @open-read-stream!
      done!


  open-read-stream: ->
    child_process.exec 'cat .tertestrial.tmp', (err, stdout, stderr) ~>
      | err  =>  return @emit 'error', err
      @emit 'command-received', JSON.parse(stdout)
      @open-read-stream!


  reset-named-pipe: (done) ->
    @empty-named-pipe ~>
      @delete-named-pipe!
      @create-named-pipe!
      done!



module.exports = PipeListener
