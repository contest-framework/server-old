module.exports = (template, data) ->
  for key, value of data
    template = template.replace new RegExp("{{#{key}}}", 'g'), value
  template
