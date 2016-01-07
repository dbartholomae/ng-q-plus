# Karma configuration

module.exports = (config) ->
  config.set
    # frameworks to use
    frameworks: ['mocha', 'browserify', 'chai']

    preprocessors:
      "test/*.coffee": ['browserify']

    browserify:
      debug: true
      transform: ["coffeeify"] #, "browserify-istanbul"]

    # list of files / patterns to load in the browser
    files: [
      'test/**/*.spec.coffee'
      {
        pattern: 'lib-cov/ng-q-plus.js'
        included: false
      }
    ]

    # test results reporter to use
    # possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ['dots', 'coverage', 'threshold']

    coverageReporter:
      dir: ''
      reporters: [
        {
          type: "html"
          subdir: "html"
        }
        {
          type: "lcovonly"
          subdir: "lcov"
          file: "coverage.txt"
        }
      ]

    thresholdReporter:
      statements: 90
      branches: 90
      functions: 90
      lines: 90

    # enable / disable colors in the output (reporters and logs)
    colors: true

    # level of logging
    # possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO

    # enable / disable watching file and executing tests whenever any file changes
    autoWatch: false

    # Start these browsers, currently available:
    # - Chrome
    # - ChromeCanary
    # - Firefox
    # - Opera (has to be installed with `npm install karma-opera-launcher`)
    # - Safari (only Mac; has to be installed with `npm install karma-safari-launcher`)
    # - PhantomJS
    # - IE (only Windows; has to be installed with `npm install karma-ie-launcher`)
    browsers: ['PhantomJS']

    # If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000

    # Continuous Integration mode
    # if true, it capture browsers, run tests and exit
    singleRun: true

    port: 9878