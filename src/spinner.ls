class Spinner

  start: ->
    @interval = set-timeout @_print, 1000


  stop: ->
    clear-interval @interval


  _print: ->
    process.stdout.write " \u001B[1D"



module.exports = Spinner
