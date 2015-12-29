((root, factory) ->
  if typeof define is 'function' and define.amd
    # AMD. Register as an anonymous module.
    define ['angularjs'], (angular) ->
      factory angular
  else if typeof exports is 'object' and typeof exports.nodeName isnt 'string'
    # CommonJS
    module.exports = factory require('angular')
  else
    # Browser globals
    factory(root.angular);
)(this, (angular) ->

  angular.module 'ng-q-plus', []
  .config ['$provide', ($provide) ->
    $provide.decorator '$q', ['$delegate', '$browser', ($delegate, $browser) ->
      promise = $delegate.defer().promise.constructor.prototype

      promise.isPending = -> @$$state.status <= 0
      promise.isFulfilled = -> @$$state.status is 1
      promise.isRejected = -> @$$state.status is 2

      promise.timeout = (time_ms, cb) ->
        deferred = $delegate.defer()
        $browser.defer (=>
          if @isPending()
            if typeof cb is 'function'
              cb deferred
            else
              cb ?= "Timed out after " + time_ms + " ms"
              deferred.reject cb
        ), time_ms
        @then deferred.resolve, deferred.reject, deferred.notify
        return deferred.promise

      promise.tap = (cb) ->
        @then (value) -> cb value; return value

      promise.get = (attr) ->
        @then (o) -> o[attr]

      promise.set = (attr, val) ->
        @then (o) ->
          $delegate.resolve val
          .then (val) ->
            o[attr] = val
            return o

      promise.post = (method, args) ->
        @then (o) -> o[method].apply o, args

      promise.invoke = promise.send = (method, args...) ->
        @then (o) -> o[method].apply o, args

      promise.keys = ->
        @then (o) -> Object.keys o

      promise.fapply = (args) ->
        @then (f) -> f.apply undefined, args

      promise.fcall = (args...) ->
        @then (f) -> f.apply undefined, args

      promise.all = promise.props = ->
        @then (arr) -> $delegate.all arr

      promise.map = (cb) ->
        @all().then (arr) ->
          if Array.isArray arr
            return $delegate.all arr.map cb
          else
            obj = {}
            for key, value of arr
              obj[key] = cb key, value
            return $delegate.all obj

      promise.each = (cb) ->
        @map (el) -> cb el; el

      return $delegate
    ]
  ]
  .name
)
