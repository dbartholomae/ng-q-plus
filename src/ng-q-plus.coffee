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
    factory(root.angular)
)(this, (angular) ->

  angular.module 'ng-q-plus', []
  .config ['$provide', ($provide) ->
    $provide.decorator '$q', ['$delegate', '$browser', ($delegate, $browser) ->
      Promise = $delegate.defer().promise.constructor

      # An extended promise
      class ExtendedPromise extends Promise
        # Returns true if the promise is pending
        # @return [Boolean] true if the promise is pending
        isPending: -> @$$state.status <= 0

        # Returns true if the promise is fulfilled
        # @return [Boolean] true if the promise is fulfilled
        isFulfilled: -> @$$state.status is 1

        # Returns true if the promise is rejected
        # @return [Boolean] true if the promise is rejected
        isRejected: -> @$$state.status is 2

        # Checks after `time_ms` milliseconds whether the promise is still
        # pending and rejects or calls a callback if it is.
        # `timeout` is implemented via `$browser.defer`. In tests it has to be
        # flushed via `$browser.defer.flush()`.
        #
        # @overload timeout(time_ms)
        #   After timeout rejects with "Timed out after {{time_ms}} ms".
        #   @param time_ms [Integer] The time before timeout in milliseconds
        #   @return [Promise] The original promise unless timed out
        #
        # @overload timeout(time_ms, err)
        #   After timeout rejects with "{{err}}".
        #   @param time_ms [Integer] The time before timeout in milliseconds
        #   @param err [String] The rejection message to use if timed out
        #   @return [Promise] The original promise unless timed out
        #
        # @overload timeout(time_ms, cb)
        #   After timeout calls cb(deferred) with the deferred object for this
        #   promise.
        #   @param time_ms [Integer] The time before timeout in milliseconds
        #   @param cb [Function] Is called with the deferred object for this promise
        #   @return [Promise] The original promise unless timed out
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

        # Equivalent to `then (value) -> cb value; return value`
        # @param cb [Function] To be called with the value of the original promise if fulfilled
        # @return [Promise] Fulfills and rejects with the original one
        tap: (cb) ->
          @then (value) -> cb value; return value

        # Equivalent to `then (o) -> o[attr]`
        # @param attr [String] The attribute to get
        # @return [Promise] The property of the value of the original promise
        get: (attr) ->
          @then (o) -> o[attr]

        # If `val` and `attr` are not promises this is equivalent to
        # `tap (o) -> o[attr] = val`. If `val` or `attr` are promises these get
        # resolved and `set` works as written above. Please note that this can
        # lead to side effects.
        # @param attr [String] The attribute to set
        # @param val [*] The new value of the attribute
        # @return [Promise] The adjusted object
        set: (attr, val) ->
          @then (o) ->
            $delegate.resolve attr
            .then (attr) ->
              $delegate.resolve val
              .then (val) ->
                o[attr] = val
                return o

        # Equivalent to `then (o) -> o[method].apply o, args`
        # @param method [String] The name of the method to call
        # @param args [Array] The arguments for the method
        # @return [Promise] The result of calling the method
        post: (method, args) ->
          @then (o) -> o[method].apply o, args

        # Equivalent to `then (o) -> o[method].apply o, [arg1, arg2, ...]`
        # @param method [String] The name of the method to call
        # @param (args...) [*] The arguments for the method
        # @return [Promise] The result of calling the method
        send: (method, args...) ->
          @then (o) -> o[method].apply o, args

        # Alternative name for `invoke`
        # @see ExtendedPromise#send
        invoke: -> @send arguments...

        # Equivalent to `then (o) -> Object.keys o`
        # @return [Promise] The keys of the value of the original promise
        keys: ->
          @then (o) -> Object.keys o

        # Equivalent to `then (f) -> f.apply undefined, args`
        # @param args [Array] The arguments for the call
        # @return [Promise] The result of f
        fapply: (args) ->
          @then (f) -> f.apply undefined, args

        # Equivalent to `then (f) -> f.apply undefined, [arg1, arg2, ...]`
        # @param (args...) [Array] The arguments for the call
        # @return [Promise] The result of f
        fcall: (args...) ->
          @then (f) -> f.apply undefined, args

        # Equivalent to `then (arr) -> $q.all arr`
        # @return [Promise] The object with all its values resolved
        all: ->
          @then (arr) -> $delegate.all arr

        # Alternative name for `all`
        # @see ExtendedPromise#all
        props: -> @all arguments...

        # For promises for arrays equivalent to
        # `all().then (arr) -> $q.all arr.map cb`.
        # For promises for objects `obj` the callback gets called as
        # `cb(key, obj[key])` for all own properties of `obj` and uses the
        # results from the callback to update these values.
        # @param cb [Function] To be called on all values of the promises value
        # @return [Promise] The object with its values modified
        map: (cb) ->
          @all().then (arr) ->
            if Array.isArray arr
              return $delegate.all arr.map cb
            else
              obj = {}
              for key, value of arr
                obj[key] = cb key, value
              return $delegate.all obj

        # Equivalent to `@map (el) -> cb el; el`
        # results from the callback to update these values.
        # @see ExtendedPromise#map
        # @param cb [Function] To be called on all values of the promises value
        # @return [Promise] The object with its values unmodified
        each: (cb) ->
          @map (el) -> cb el; el

        # Calls `cb(v0, v1, v2, ...)` with `v0` being the value of the resolved
        # promise itself and `v1, v2, ...` being the values of the resolved
        # promises `v1, v2, ...`. It returns a promise for the result of `cb`.
        # If any promise rejects, it returns a promise rejected with the same
        # reason.
        # @param promises... [Promise] The promises to inject
        # @param cb [Function] To be called with the values of all promises.
        # @return [Promise] The result of the callback
        join: (promises..., cb) ->
          $delegate.all [this, promises...]
          .then (promises) -> cb promises...

      Promise.prototype = ExtendedPromise.prototype

      return $delegate
    ]
  ]
  .name
)
