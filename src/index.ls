require! {
  chalk : {bold, cyan, dim}
  chokidar
  './command-runner' : CommandRunner
  docopt: {docopt}
  './config-file' : ConfigFile
  fs
  './helpers/error-message' : {abort, error}
  './helpers/is-duplicate-checker' : is-duplicate
  './helpers/reset-terminal'
  './helpers/run-mode-checker' : runs-in-foreground
  interpret
  liftoff : Liftoff
  '../package.json' : pkg
  path
  './pipe-listener' : PipeListener
  './setup-wizard'
  './spinner' : Spinner
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

    spinner = new Spinner!

    config = new ConfigFile env.config-path
    command-runner = new CommandRunner config
    pipe-path = path.join process.cwd!, '.tertestrial.tmp'
    pipe-listener = new PipeListener pipe-path
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
      spinner.stop!
      reset-terminal!
      console.log 'Reloading configuration\n'
      config := new ConfigFile env.config-path
      command-runner.update-config config
      if process.env.TERTESTRIAL_PREVENT_APP_NAP
        spinner.start!

    process.on 'SIGINT', ->
      console.log '\n\nSee you next time! :)\n'
      pipe-listener.cleanup!
      process.exit!

      if process.env.TERTESTRIAL_PREVENT_APP_NAP
      spinner.start!
