var formatOptions = {
  'snippetSyntax': 'node_modules/cucumber-snippets-livescript'
};

var common = [
  '--compiler ls:livescript',
  '--fail-fast',
  '--require features',
  '--format-options \'' + JSON.stringify(formatOptions) + "\'"
].join(' ');

module.exports = {
  "default": common
};
