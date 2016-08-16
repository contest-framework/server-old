require! {
  'chalk' : {bold, red}
  'child_process'
}


module.exports = ->

  @register-handler 'BeforeFeatures', (_, done) ->
    process = child_process.spawn-sync 'node_modules/.bin/build', encoding: 'utf8'
    if process.status > 0
      console.log bold red "\nError compiling Livescript\n"
      console.log process.stdout if process.stdout
      console.log process.stderr if process.stderr
    done process.status
