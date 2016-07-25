require! {
  'observable-process' : ObservableProcess
  'process'
}


# Returns whether the current script runs in the background
module.exports = function runs-in-foreground done
  checker-process = new ObservableProcess ['ps', '-o', 'stat=', '-p', process.pid], console: off
    ..on 'ended', ->
      done checker-process.full-output!.includes '+'
