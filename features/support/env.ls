require! {
  'fs'
  'rimraf'
}


module.exports = ->

  @set-default-timeout 3000

  @Before ->
    rimraf.sync 'tmp'
    fs.mkdir-sync 'tmp'
    @processes-to-kill = []

  @After ->
    @processes-to-kill.for-each (.kill!)

  @Before tags: ['@verbose'], ->
    @verbose = on

  @After tags: ['@verbose'], ->
    @verbose = off
