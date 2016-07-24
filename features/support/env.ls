module.exports = ->

  @set-default-timeout 1000

  @After ->
    if @process
      @process.kill!

  @Before tags: ['@verbose'], ->
    @verbose = on

  @After tags: ['@verbose'], ->
    @verbose = off
