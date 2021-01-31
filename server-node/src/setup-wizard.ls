require! {
  chalk : {bold, cyan, green}
  fs
  inquirer
  path
  'prelude-ls' : {map, sort}
  'require-yaml'
  'shelljs' : {cp}
}


function built-in-action-sets
  files = fs.readdir-sync(path.join __dirname, '..' 'actions')
    |> map -> path.basename it, path.extname(it)
    |> sort
  for file in files
    content = require path.join(__dirname, '..' 'actions' "#{file}.yml")
    { name: content.name, value: file }


function create-custom-configuration template
  cp path.join(__dirname, '..' 'actions' "#{template}.yml"), 'tertestrial.yml'
  console.log """

    I have created configuration file #{cyan 'tertestrial.yml'} as a starter.
    Please adapt it to your project.

    """


module.exports = ->
  console.log bold 'Tertestrial setup wizard\n'
  questions =
    message: 'Which configuration to you want to use as a starting point?'
    type: 'list'
    name: 'built-in'
    choices: built-in-action-sets!
  inquirer.prompt(questions).then (answers) ->
    create-custom-configuration answers['built-in']
