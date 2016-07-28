require! {
  'chalk' : {bold, cyan, green}
  'fs'
  'inquirer'
  'js-yaml' : yaml
  'path'
  'prelude-ls' : {map, sort}
  'shelljs/global'
}


function built-in-mappings
  mappings = fs.readdir-sync(path.join __dirname, '..' 'mappings')
    |> map -> path.basename it, path.extname(it)
    |> sort
  for mapping in mappings
    content = yaml.safe-load fs.read-file-sync(path.join __dirname, '..' 'mappings' "#{mapping}.yml")
    { name: content.name, value: mapping }


function create-builtin-config mapping
  fs.write-file-sync 'tertestrial.yml', "mappings: #{mapping}"
  console.log """

  Created configuration file #{cyan 'tertestrial.yml'}.
  You are done with the setup. Happy testing!

  """


function create-custom-mapping template
  cp path.join(__dirname, '..' 'mappings' "#{template}.yml"), 'tertestrial.yml'
  console.log """

  I have created configuration file #{cyan 'tertestrial.yml'} as a starter.
  Please adapt it to your project.

  """


module.exports = ->
  console.log bold 'Tertestrial setup wizard\n'
  console.log 'We are going to create a Tertestrial configuration file together.\n'
  questions =
    message: 'Do you want to use a built-in mapping?'
    type: 'list'
    name: 'mapping'
    choices: [{name: 'No, I want to build my own custom mapping', value: 'no'},
              new inquirer.Separator!].concat built-in-mappings!
  inquirer.prompt(questions).then (answers) ->
    if answers.mapping isnt 'no'
      create-builtin-config answers.mapping
      process.exit!

    console.log '\nOkay, creating a custom mapping for you.\n'
    questions =
      message: 'Which mapping to you want to use as a starting point?'
      type: 'list'
      name: 'mapping'
      choices: built-in-mappings!
    inquirer.prompt(questions).then (answers) ->
      create-custom-mapping answers.mapping
