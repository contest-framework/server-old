require! {
  'fs'
  'rimraf'
}


module.exports = ->

  @set-default-timeout 2000

  @Before ->
    rimraf.sync 'tmp'
    fs.mkdir-sync 'tmp'
    @processesToKill = []

  @After ->
    @processesToKill.forEach (process) -> process.kill!

  @Before tags: ['@verbose'], ->
    @verbose = on

  @After tags: ['@verbose'], ->
    @verbose = off
