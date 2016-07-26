require! {
  'chalk' : {bold, cyan, dim}
  './command-runner' : CommandRunner
  './config-file' : ConfigFile
  'fs'
  './helpers/reset-terminal'
  './helpers/run-mode-checker'
  '../package.json' : {version}
  './pipe-listener' : PipeListener
  './setup-wizard'
}


if process.argv.length is 3 and process.argv[2] is '--setup'
  setup-wizard!
  return


reset-terminal!
console.log dim "Tertestrial server #{version}\n"
(runs-in-foreground) <- run-mode-checker
if runs-in-foreground
  console.log "#{bold 'ctrl-c'} to exit"
else
  console.log "to exit, run #{cyan 'fg'}, then hit #{bold '[ctrl-c]'}\n"

config = new ConfigFile
command-runner = new CommandRunner config
pipe-listener = new PipeListener
  ..on 'command-received', command-runner.run-command


console.log '\nrunning'
