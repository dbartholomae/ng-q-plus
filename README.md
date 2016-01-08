# ng-q-plus
[![NPM version](https://badge.fury.io/js/ng-q-plus.svg)](https://npmjs.org/package/ng-q-plus)
[![Build Status](https://travis-ci.org/dbartholomae/ng-q-plus.svg?branch=master)](https://travis-ci.org/dbartholomae/ng-q-plus)
[![Coverage Status](https://coveralls.io/repos/dbartholomae/ng-q-plus/badge.svg?branch=master&service=github)](https://coveralls.io/github/dbartholomae/ng-q-plus?branch=master)
[![Dependency Status](https://david-dm.org/dbartholomae/ng-q-plus.svg?theme=shields.io)](https://david-dm.org/dbartholomae/ng-q-plus)
[![devDependency Status](https://david-dm.org/dbartholomae/ng-q-plus/dev-status.svg)](https://david-dm.org/dbartholomae/ng-q-plus#info=devDependencies)
[![GitHub license](https://img.shields.io/github/license/dbartholomae/ng-q-plus.svg)]()

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
Each promise gets the new methods as defined in the ExtendedPromise class which can be found in the [documentation](https://cdn.rawgit.com/dbartholomae/ng-q-plus/master/doc/index.html).
