require! {
  'chalk' : {red}
}


function abort error-message
  error error-message
  process.exit 1


function error message
  console.log red "\nError: #{message}"



module.exports = {abort, error}
