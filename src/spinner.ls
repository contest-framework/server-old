class Spinner

  start: ->
    console.log 'preventing app nap'
    @interval = set-interval @_print, 10_000


  stop: ->
    clear-interval @interval


  _print: ->
    # Print a space, then moves the cursor 1 position to the left
    process.stdout.write " \u001B[1D"



module.exports = Spinner
