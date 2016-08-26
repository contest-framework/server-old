require! {
  'child_process' : {exec-sync}
}


function get-process-cwd process-id
  result = exec-sync "lsof -p #{process-id} -d cwd -a -Fn", encoding: 'utf8'
  result.split('\n')[1].slice(1)


function get-tertestrial-process-ids
  exec-sync 'ps -o command,pid', encoding: 'utf8'
    .split '\n'
    .slice 1
    .map (str) ->
      [command, pid] = str.split /\s+(?=\S*$)/
      {command, pid}
    .filter ({command, pid}) -> command is 'tertestrial'
    .map ({pid}) -> pid


module.exports = function is-duplicate
  pid = process.pid.toString()
  cwd = process.cwd()
  duplicates = get-tertestrial-process-ids!
    .filter (duplicatePid) -> pid isnt duplicatePid
    .map get-process-cwd
    .filter (duplicateCwd) -> cwd is duplicateCwd
  duplicates.length > 0
