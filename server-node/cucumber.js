var formatOptions = {
  snippetSyntax: 'node_modules/cucumber-snippets-livescript'
};

var common = [
  '--compiler ls:livescript',
  '--fail-fast',
  '--format-options \'' + JSON.stringify(formatOptions) + "\'",
  '--require features'
].join(' ');

module.exports = {
  default: common
};
