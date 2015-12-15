module.exports = (config) ->
  settings = require('./karma.conf.coffee')(config)

  settings.browserify =
    debug: true
    transform: ["coffeeify"]

  settings.preprocessors =
    "test/*.coffee": ['browserify']
    "lib/*.js": ['browserify']

  settings.frameworks =
    ['mocha', 'browserify', 'chai']

  settings.files = [
    'test/**/*.spec.coffee'
  ]

  settings.port = 9878

  config.set settings
