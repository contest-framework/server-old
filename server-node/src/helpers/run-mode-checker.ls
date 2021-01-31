require! {
  child_process : {exec-sync}
}


# Returns whether the current script runs in the background
module.exports = function runs-in-foreground
  exec-sync("ps -o stat= -p #{process.pid}", encoding: 'utf8').includes '+'
