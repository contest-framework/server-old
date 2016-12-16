require! {
  child_process : {exec-sync}
}


function get-process-cwd process-id
  exec-sync "lsof -p #{process-id} -d cwd -a -Fn", encoding: 'utf8'
    .split('\n')[*-2]
    .slice 1


function get-tertestrial-process-ids
  exec-sync 'ps -o command,pid', encoding: 'utf8'
    .split '\n'
    .slice 1
    .map (.split /\s+(?=\S*$)/)
    .map ([command, pid]) -> {command, pid}
    .filter (.command is 'tertestrial')
    .map (.pid)


module.exports = function is-duplicate
  my-pid = process.pid.toString!
  my-cwd = process.cwd!
  get-tertestrial-process-ids!
    .filter (isnt my-pid)
    .map get-process-cwd
    .filter (is my-cwd)
    .length > 0
