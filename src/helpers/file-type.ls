require! path


# Returns the extension of the given file path
module.exports = function file-type file-name
  path.extname(file-name).substring 1
