# ng-q-plus@0.0.1
**ng-q-plus** is an angular module enhancing $q promises with additional features

```coffeescript
angular.module 'app', [require('ng-q-plus')]
.service 'myService', ['$q', ($q) ->
  $q.when a: 1
  .get('a')
  .then (value) ->
    console.log value # = 1
]
```

## API

The module can be required via browserify require, as an AMD module via requirejs or as a global, if window.angular is
present. It creates the angular module 'ng-q-plus' and exports its name. This module augments the existing
`$q` service, it does not create a service of its own.
Each promise gets the following new methods:

### `isPending()`
Returns true if the promise is pending (`promise.$$state.status <= 0`)
### `isFulfilled()`
Returns true if the promise is fulfilled (`promise.$$state.status == 1`)
### `isRejected()`
Returns true if the promise is rejected (`promise.$$state.status == 2`)

### `timeout(time_ms, cb)`
Checks after `time_ms` milliseconds whether the promise is still pending. If it is, then `cb` is called with
the deferred object for this promise as an argument. If `cb` isn't a function, the promise instead rejects
with `cb` as error. If `cb` is `undefined`, the promise rejects with `"Timed out after " + time_ms + " ms"`. 
`timeout` is implemented via `$browser.defer`. In tests it has to be flushed via `$browser.defer.flush()`.

### `tap(cb)`
Equivalent to `then (value) -> cb value; return value`

### `get(attr)`
Equivalent to `then (o) -> o[attr]`

### `post(method, args)`
Equivalent to `then (o) -> o[method].apply o, args`

### `invoke(method, arg1, arg2, ...)`
Equivalent to `then (o) -> o[method].apply o, [arg1, arg2, ...]`

### `send(method, arg1, arg2, ...)`
Alternative name for `invoke`

### `keys()`
Equivalent to `then (o) -> Object.keys o`

### `fapply(args)`
Equivalent to `then (f) -> f.apply undefined, args`

### `fcall(arg1, arg2, ...)`
Equivalent to `then (f) -> f.apply undefined, [arg1, arg2, ...]`