class Spinner

  start: ->
    console.log 'preventing app nap'
    @interval = set-interval @_print, 5_000


  stop: ->
    clear-interval @interval


  _print: ->
    process.stdout.write " \u001B[1D"



module.exports = Spinner
