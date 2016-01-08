((root, factory) ->
  if typeof define is 'function' and define.amd
    # AMD. Register as an anonymous module.
    define ['angular'], (angular) ->
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
      Promise = $delegate.defer().promise.constructor

      class ExtendedPromise extends Promise
        isPending: -> @$$state.status <= 0
        isFulfilled: -> @$$state.status is 1
        isRejected: -> @$$state.status is 2

        timeout: (time_ms, cb) ->
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

        tap: (cb) ->
          @then (value) -> cb value; return value

        get: (attr) ->
          @then (o) -> o[attr]

        set: (attr, val) ->
          @then (o) ->
            $delegate.resolve attr
            .then (attr) ->
              $delegate.resolve val
              .then (val) ->
                o[attr] = val
                return o

        post: (method, args) ->
          @then (o) -> o[method].apply o, args

        send: (method, args...) ->
          @then (o) -> o[method].apply o, args

        invoke: -> @send arguments...

        keys: ->
          @then (o) -> Object.keys o

        fapply: (args) ->
          @then (f) -> f.apply undefined, args

        fcall: (args...) ->
          @then (f) -> f.apply undefined, args

        all: ->
          @then (arr) -> $delegate.all arr

        props: -> @all arguments...

        map: (cb) ->
          @all().then (arr) ->
            if Array.isArray arr
              return $delegate.all arr.map cb
            else
              obj = {}
              for key, value of arr
                obj[key] = cb key, value
              return $delegate.all obj

        each: (cb) ->
          @map (el) -> cb el; el

        join: (promises..., cb) ->
          $delegate.all [@, promises...]
          .then (promises) -> cb promises...

      Promise.prototype = ExtendedPromise.prototype

      return $delegate
    ]
  ]
  .name
)
