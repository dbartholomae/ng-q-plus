describe "An ng-q-plus module", ->
  $q = null
  $rootScope = null
  $browser = null

  before (done) ->
    if requirejs?
      define 'angularjs', -> angular
      requirejs ['base/lib/ng-q-plus'], (ngQPlus) ->
        expect(-> angular.mock.module('ng-q-plus')).to.not.throw
        done()
    else if require?
      require '../lib/ng-q-plus.js'
      require 'angular-mocks'
      done()
    else done()

  beforeEach ->
    angular.mock.module 'ng-q-plus'
    inject ($injector) ->
      $q = $injector.get '$q'
      $rootScope = $injector.get '$rootScope'
      $browser = $injector.get '$browser'

  testPromise = (promiseFactory) ->
    it "is thenable", (done) ->
      promiseFactory.fulfilled("value")
      .then (val) ->
        expect(val).to.equal "value"
        done()
      $rootScope.$digest()

    describe "shows its status correctly", ->
      it "when pending", ->
        promise = promiseFactory.pending()
        $rootScope.$digest()
        expect(promise.isPending()).to.be.true
        expect(promise.isFulfilled()).to.be.false
        expect(promise.isRejected()).to.be.false

      it "when fulfilled", (done) ->
        promise = promiseFactory.fulfilled()
        promise.then ->
          expect(promise.isPending()).to.be.false
          expect(promise.isFulfilled()).to.be.true
          expect(promise.isRejected()).to.be.false
          done()
        $rootScope.$digest()

      it "when rejected", (done) ->
        promise = promiseFactory.rejected()
        promise.catch ->
          expect(promise.isPending()).to.be.false
          expect(promise.isFulfilled()).to.be.false
          expect(promise.isRejected()).to.be.true
          done()
        $rootScope.$digest()

    describe "with a timeout", ->
      it "rejects if the time runs out before the promise is resolved", (done) ->
        promise = promiseFactory.pending().timeout 100
        $rootScope.$digest()
        expect(promise.isPending()).to.be.true
        promise.catch (err) ->
          expect(err).to.equal "Timed out after 100 ms"
          done()
        $browser.defer.flush()
        $rootScope.$digest()
      it "rejects if the promise is rejected", (done) ->
        promise = promiseFactory.rejected("error").timeout 100
        promise.catch (err) ->
          expect(err).to.equal "error"
          done()
        $browser.defer.flush()
        $rootScope.$digest()
      it "resolves if the promise is resolved", (done) ->
        promise = promiseFactory.fulfilled("value").timeout 100
        promise.then (value) ->
          expect(value).to.equal "value"
          done()
        $browser.defer.flush()
        $rootScope.$digest()

    it "allows to tap in without side-effects", (done) ->
      promiseFactory.fulfilled("value").tap (val) ->
        expect(val).to.deep.equal "value"
        return []
      .then (val) ->
        expect(val).to.deep.equal "value"
        done()
      $rootScope.$digest()

    it "allows to get attribute values", (done) ->
      promiseFactory.fulfilled(test: "value").get('test')
      .then (val) ->
        expect(val).to.equal "value"
        done()
      $rootScope.$digest()

    it "allows to set attribute values", (done) ->
      promiseFactory.fulfilled(test: "value").set('test', promiseFactory.fulfilled "new value")
      .then (val) ->
        expect(val).to.deep.equal {test: "new value"}
        done()
      $rootScope.$digest()

    it "allows to post methods", (done) ->
      promiseFactory.fulfilled(test: (val)-> val).post('test', ["value"])
      .then (val) ->
        expect(val).to.equal "value"
        done()
      $rootScope.$digest()

    it "allows to invoke methods", (done) ->
      promiseFactory.fulfilled(test: (val)-> val).invoke('test', "value")
      .then (val) ->
        expect(val).to.equal "value"
        done()
      $rootScope.$digest()

    it "allows to send methods", (done) ->
      promiseFactory.fulfilled(test: (val)-> val).send('test', "value")
      .then (val) ->
        expect(val).to.equal "value"
        done()
      $rootScope.$digest()

    it "allows to get keys", (done) ->
      promiseFactory.fulfilled(value: "key").keys()
      .then (val) ->
        expect(val).to.deep.equal ["value"]
        done()
      $rootScope.$digest()

    it "allows to apply functions", (done) ->
      promiseFactory.fulfilled((val) -> val).fapply(["value"])
      .then (val) ->
        expect(val).to.equal "value"
        done()
      $rootScope.$digest()

    it "allows to call functions", (done) ->
      promiseFactory.fulfilled((val) -> val).fcall("value")
      .then (val) ->
        expect(val).to.equal "value"
        done()
      $rootScope.$digest()

    it "allows to convert a promise for an array of promises into a promise for an array", (done) ->
      arr = [promiseFactory.fulfilled(1), promiseFactory.fulfilled(2)]
      promiseFactory.fulfilled(arr).all()
      .then (arr) ->
        expect(arr).to.deep.equal [1, 2]
        done()
      $rootScope.$digest()

    it "allows to convert a promise for a hash of promises into a promise for a hash", (done) ->
      obj = {a: promiseFactory.fulfilled(1), b: promiseFactory.fulfilled(2)}
      promiseFactory.fulfilled(obj).all()
      .then (obj) ->
        expect(obj).to.deep.equal {a: 1, b: 2}
        done()
      $rootScope.$digest()

    it "allows to map a promise for an array", (done) ->
      arr = [promiseFactory.fulfilled(1), promiseFactory.fulfilled(2)]
      promiseFactory.fulfilled(arr)
      .map (el) -> "a" + el
      .then (arr) ->
        expect(arr).to.deep.equal ["a1", "a2"]
        done()
      $rootScope.$digest()

    it "allows to map a promise for an object", (done) ->
      obj = {a: promiseFactory.fulfilled(1), b: promiseFactory.fulfilled(2)}
      promiseFactory.fulfilled(obj)
      .map (key, value) ->
        if key is 'a'
          return 3
        else if key is 'b'
          return 4
      .then (obj) ->
        expect(obj).to.deep.equal {a: 3, b: 4}
        done()
      $rootScope.$digest()

    it "allows to use each for a promise for an array", (done) ->
      arr = [promiseFactory.fulfilled(1), promiseFactory.fulfilled(2)]
      result = []
      promiseFactory.fulfilled(arr)
      .each (el) ->
        result.push el
        return "a" + el
      .then (arr) ->
        expect(result).to.deep.equal [1, 2]
        expect(arr).to.deep.equal [1, 2]
        done()
      $rootScope.$digest()

  describe "that creates a promise via defer()", ->
    testPromise.call this,
      pending: -> $q.defer().promise
      fulfilled: (val) ->
        deferred = $q.defer()
        deferred.resolve val
        return deferred.promise
      rejected: (err) ->
        deferred = $q.defer()
        deferred.reject err
        return deferred.promise

  describe "that creates a promise via resolve and reject", ->
    testPromise.call this,
      pending: -> $q.defer().promise
      fulfilled: (val) -> $q.resolve (val)
      rejected: (err) -> $q.reject err

  describe "that creates a promise via when", ->
    testPromise.call this,
      pending: -> $q.when $q.defer().promise
      fulfilled: (val) -> $q.when val
      rejected: (err) -> $q.when $q.reject (err)

  describe "that creates a promise via all", ->
    testPromise.call this,
      pending: -> $q.all [$q.defer().promise]
      fulfilled: (val) -> $q.all([val]).get(0)
      rejected: (err) -> $q.all([$q.reject err]).get(0)

  describe "that is loaded", ->
    it "exports the module name", (done) ->
      if requirejs?
        requirejs ['base/lib/ng-q-plus.js'], (name) ->
          expect(name).to.equal 'ng-q-plus'
          done()
      else if require?
        expect(require('../lib/ng-q-plus.js')).to.equal 'ng-q-plus'
        done()
      else done()
