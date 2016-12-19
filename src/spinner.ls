require! {
  'wait' : {repeat, wait}
}


class Spinner

  start: ->
    @interval = repeat 1000, @_print


  stop: ->
    clear-interval @interval


  _print: ->
    process.stdout.write " \u001B[1D"



module.exports = Spinner
