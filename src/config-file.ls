require! {
  './helpers/file-type'
  'fs'
  'glob'
  'livescript'
  'path'
  'prelude-ls' : {capitalize}
  'remove-value'
}


# Represents the Tertestrial config file
#
# Config files can be written in a variety of languages
# like JavaScript, CoffeeScript, LiveScript, etc
class ConfigFile

  ->
    config-file-name = @_get-config-file-name!
    compiler-method-name = "_compile#{capitalize file-type config-file-name}"
    config = @[compiler-method-name] fs.read-file-sync(config-file-name, 'utf8')
    @mappings = @_standardize-mappings config.mappings


  # Compiles the given LSON text, and returns a hash
  _compile-ls: (content) ->
    eval livescript.compile "#{content}", bare: yes, header: no


  # Finds the Tertestrial config file and returns its name
  _get-config-file-name: ->
    config-files = glob.sync 'tertestrial.*'
    remove-value config-files, 'tertestrial.tmp'
    if config-files.length is 0
      console.log red "Error: cannot find configuration file"
      process.exit 1
    if config-files.length > 1
      console.log red "Multiple config files found: #{config-files.join ', '}"
      process.exit 1
    config-files[0]


  _standardize-mappings: (mappings) ->
    switch mapping-type = typeof! mappings
      | 'Object'  =>  [mappings]
      | 'Array'   =>  mappings
      | _         =>  throw new Error "Error: unknown mapping type: #{mapping-type}"



module.exports = ConfigFile
