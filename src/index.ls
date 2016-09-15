require! {
  'chalk' : {bold, cyan, dim}
  'chokidar'
  './command-runner' : CommandRunner
  'docopt': {docopt}
  './config-file' : ConfigFile
  'fs'
  './helpers/error-message' : {abort, error}
  './helpers/is-duplicate-checker' : is-duplicate
  './helpers/reset-terminal'
  './helpers/run-mode-checker' : runs-in-foreground
  'interpret'
  'liftoff' : Liftoff
  '../package.json' : pkg
  './pipe-listener' : PipeListener
  './setup-wizard'
  'update-notifier'
}


update-notifier({pkg}).notify!

Tertestrial = new Liftoff name: 'tertestrial', config-name: 'tertestrial', extensions: interpret.extensions
  ..launch {}, (env) ->

    doc = """
      Usage:
        tertestrial
        tertestrial (help | setup | version)

      Subcommands:
        help      Show this screen
        setup     Run a setup wizard to generate a config file
        version   Show version
      """

    options = docopt doc, help: false, version: pkg.version

    switch
      | options.help     =>  return console.log doc
      | options.setup    =>  return setup-wizard!
      | options.version  =>  return console.log pkg.version

    if is-duplicate!
      abort 'Tertestrial is already running in the current directory.'

    reset-terminal!
    console.log dim "Tertestrial server #{pkg.version}\n"

    config = new ConfigFile env.config-path
    command-runner = new CommandRunner config
    pipe-listener = new PipeListener process.cwd()
      ..on 'command-received', command-runner.run-command
      ..on 'command-parse-error', error
      ..on 'error', (err) -> throw new Error err
      ..listen ->
        if runs-in-foreground!
          console.log "#{bold 'ctrl-c'} to exit"
        else
          console.log "to exit, run #{cyan 'fg'}, then hit #{bold '[ctrl-c]'}\n"
        console.log '\nrunning'

    chokidar.watch(env.config-path).on 'change', (path) ->
      reset-terminal!
      console.log 'Reloading configuration\n'
      config := new ConfigFile env.config-path
      command-runner.update-config config

    process.on 'SIGINT', ->
      console.log '\n\nSee you next time! :)\n'
      pipe-listener.cleanup!
      process.exit!
