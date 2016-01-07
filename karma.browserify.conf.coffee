module.exports = (config) ->
  settings = require('./karma.conf.coffee')(config)

  settings.browserify =
    debug: true
    transform: ["coffeeify", ["browserify-istanbul",
      instrumenterConfig: { embedSource: true }
    ]]

  settings.preprocessors =
    "test/*.coffee": ['browserify']
    "lib/*.js": ['browserify', 'coverage']

  settings.frameworks =
    ['mocha', 'browserify', 'chai']

  settings.reporters.push 'coverage'
  settings.coverageReporter =
    dir: 'reports/'

  settings.reporters.push 'threshold'
  settings.thresholdReporter =
    statements: 90
    branches: 60
    functions: 90
    lines: 90

  settings.files = [
    'test/**/*.spec.coffee'
  ]

  settings.port = 9878

  config.set settings
