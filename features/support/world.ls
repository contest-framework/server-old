require! {
  'child_process'
  'dim-console'
  'fs'
  'observable-process' : ObservableProcess
  'path'
  'wait' : {wait}
}


World = !->

  @create-file = (name, content) ->
    fs.write-file-sync path.join('tmp', name), content


  @file-exists = (name) ->
    fs.stat-sync path.join(@root-dir, name)

  @run-process = (command) ->
    child_process.exec-sync command, cwd: @root-dir


  @send-command = (command, done) ->
    wait 10, ~>
      fs.append-file-sync path.join(@root-dir, '.tertestrial.tmp'), command
      done!


  @start-process = (command, done = ->) ->
    args =
      console: off
      cwd: @root-dir
    if @verbose
      args.console = dim-console.console
    @process = new ObservableProcess command, args
      ..wait 'running', done
      ..on 'ended', (@exit-code) ~> done "App crashed with code #{@exit-code}!\n\n#{@process.full-output!}"



module.exports = ->
  @World = World
