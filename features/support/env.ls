require! {
  'fs'
  'rimraf'
}


module.exports = ->

  @set-default-timeout 2000

  @Before ->
    rimraf.sync 'tmp'
    fs.mkdir-sync 'tmp'
    @processes-to-kill = []

  @After ->
    @processes-to-kill.for-each (.kill!)
    rimraf.sync @root-dir unless @root-dir.includes 'example-applications'


  @Before tags: ['@verbose'], ->
    @verbose = on

  @After tags: ['@verbose'], ->
    @verbose = off
