require! {
  'chalk' : {bold, cyan, green}
  'fs'
  'inquirer'
  'js-yaml' : yaml
  'path'
  'prelude-ls' : {map, sort}
  'shelljs/global'
}


function built-in-action-sets
  files = fs.readdir-sync(path.join __dirname, '..' 'actions')
    |> map -> path.basename it, path.extname(it)
    |> sort
  for file in files
    content = yaml.safe-load fs.read-file-sync(path.join __dirname, '..' 'actions' "#{file}.yml")
    { name: content.name, value: file }


function create-builtin-config file-name
  fs.write-file-sync 'tertestrial.yml', "actions: #{file-name}"
  console.log """

  Created configuration file #{cyan 'tertestrial.yml'}.
  You are done with the setup. Happy testing!

  """


function create-custom-configuration template
  cp path.join(__dirname, '..' 'actions' "#{template}.yml"), 'tertestrial.yml'
  console.log """

    I have created configuration file #{cyan 'tertestrial.yml'} as a starter.
    Please adapt it to your project.

    """


module.exports = ->
  console.log bold 'Tertestrial setup wizard\n'
  console.log 'We are going to create a Tertestrial configuration file together.\n'
  questions =
    message: 'Do you want to use a built-in configuration?'
    type: 'list'
    name: 'built-in'
    choices: [{name: 'No, I want to build my own custom configuration', value: 'no'},
              new inquirer.Separator!].concat built-in-action-sets!
  inquirer.prompt(questions).then (answers) ->
    if answers['built-in'] isnt 'no'
      create-builtin-config answers['built-in']
      process.exit!

    console.log '\nOkay, creating a custom configuration for you.\n'
    questions =
      message: 'Which configuration to you want to use as a starting point?'
      type: 'list'
      name: 'built-in'
      choices: built-in-action-sets!
    inquirer.prompt(questions).then (answers) ->
      create-custom-configuration answers['built-in']
