# ng-q-plus
[![NPM version](https://badge.fury.io/js/ng-q-plus.svg)](https://npmjs.org/package/ng-q-plus)
[![Build Status](https://travis-ci.org/dbartholomae/ng-q-plus.svg?branch=master)](https://travis-ci.org/dbartholomae/ng-q-plus)
[![Coverage Status](https://coveralls.io/repos/dbartholomae/ng-q-plus/badge.svg?branch=master&service=github)](https://coveralls.io/github/dbartholomae/ng-q-plus?branch=master)
[![Dependency Status](https://david-dm.org/dbartholomae/ng-q-plus.svg?theme=shields.io)](https://david-dm.org/dbartholomae/ng-q-plus)
[![devDependency Status](https://david-dm.org/dbartholomae/ng-q-plus/dev-status.svg)](https://david-dm.org/dbartholomae/ng-q-plus#info=devDependencies)
[![GitHub license](https://img.shields.io/github/license/dbartholomae/ng-q-plus.svg)]()
[![Gitter](https://badges.gitter.im/dbartholomae/ng-q-plus.svg)](https://gitter.im/dbartholomae/ng-q-plus?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

**ng-q-plus** is an angular module enhancing $q promises with additional features

```coffeescript
require('angular').module 'app', [require('ng-q-plus')]
.service 'myService', ['$q', ($q) ->
  getPkmn = (i) -> $q.resolve { id: i, name: "Some gibberish name" }
  getDesc = (i) -> $q.resolve "This is pokemon " + i

  pokemons = $q.resolve [1..150]
  .map (i) ->
    getPkmn(i).set 'description', getDesc(i)
  .timeout 1000, "Uh oh, it took longer than 1 second to catch 'em all"
  .then (list) ->
    console.log JSON.stringify list, null, 2
    # Will print out
    # [
    #  { id: 1, name: "Some gibberisch name", description "This is pokemon 1" }
    #  { id: 2, name: "Some gibberisch name", description "This is pokemon 2" }
    #  ...
    #  { id: 150, name: "Some gibberisch name", description "This is pokemon 150" }
    # ]
]
```

## CDN

The module should be available via [npmcdn](https://npmcdn.com/) at
[https://npmcdn.com/ng-q-plus](https://npmcdn.com/ng-q-plus)

No guarantees for uptime or anything like that, though.

## API

The module can be required via browserify require, as an AMD module via requirejs or as a global, if window.angular is
present. It creates the angular module 'ng-q-plus' and exports its name. This module augments the existing
`$q` service, it does not create a service of its own.
Each promise gets the new methods as defined in the ExtendedPromise class which can be found in the [documentation](https://rawgit.com/dbartholomae/ng-q-plus/master/doc/index.html).
