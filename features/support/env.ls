require! {
  './world': World
  'cucumber': {defineSupportCode}
  'fs'
  'rimraf'
  'tmp'
}


defineSupportCode ({set-default-timeout, set-world-constructor, Before, After})->

  set-default-timeout 3000

  set-world-constructor World

  Before ->
    rimraf.sync 'tmp'
    fs.mkdir-sync 'tmp'
    @processes-to-kill = []
    @root-dir = tmp.dir-sync!.name

  After ->
    @processes-to-kill.for-each (.kill!)
    rimraf.sync @root-dir unless @root-dir.includes 'example-applications'


  Before tags: '@verbose', ->
    @verbose = on

  After tags: '@verbose', ->
    @verbose = off
