module.exports = (config) ->
  settings = require('./karma.conf.coffee')(config)
  settings.files.push 'node_modules/requirejs/require.js'
  settings.port = 9876

  config.set settings
