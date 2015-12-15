module.exports = (config) ->
  settings = require('./karma.conf.coffee')(config)
  settings.port = 9877
  config.set settings
