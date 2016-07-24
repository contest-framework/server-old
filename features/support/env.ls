require! {
  'fs'
  'rimraf'
}


module.exports = ->

  @set-default-timeout 1000

  @Before ->
    rimraf.sync 'tmp'
    fs.mkdir-sync 'tmp'

  @After ->
    if @process
      @process.kill!

  @Before tags: ['@verbose'], ->
    @verbose = on

  @After tags: ['@verbose'], ->
    @verbose = off
