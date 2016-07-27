require! {
  './helpers/error-message' : {abort}
  './helpers/file-type'
  'fs'
  'js-yaml' : yaml
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
    try
      fs.stat-sync 'tertestrial.yml'
    catch
      abort 'cannot find configuration file'
    config = yaml.safe-load fs.read-file-sync('tertestrial.yml', 'utf8')
    @mappings = config.mappings |> @_standardize-mappings |> @_prepend-empty-mapping


  _load-internal-mapping: (filename) ->
    yaml.safe-load fs.read-file-sync path.join(__dirname, '..', 'mappings', "#{filename}.yml"), 'utf8'


  _prepend-empty-mapping: (mappings) ->
    mappings.unshift {}
    mappings


  _standardize-mappings: (mappings) ->
    switch mapping-type = typeof! mappings
      | 'Object'  =>  [default: mappings]
      | 'Array'   =>  mappings
      | 'String'  =>  @_standardize-mappings @_load-internal-mapping(mappings).mappings
      | _         =>  abort "unknown mapping type: #{mapping-type}"



module.exports = ConfigFile
