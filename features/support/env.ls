require! {
  'fs'
  'rimraf'
  'tmp'
}


module.exports = ->

  @set-default-timeout 3000

  @Before ->
    rimraf.sync 'tmp'
    fs.mkdir-sync 'tmp'
    @processes-to-kill = []
    @root-dir = tmp.dir-sync!.name

  @After ->
    @processes-to-kill.for-each (.kill!)
    rimraf.sync @root-dir unless @root-dir.includes 'example-applications'


  @Before tags: ['@verbose'], ->
    @verbose = on

  @After tags: ['@verbose'], ->
    @verbose = off
