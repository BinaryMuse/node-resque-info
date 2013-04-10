sinon = require 'sinon'
chai = require 'chai'
should = chai.should()
sinonChai = require 'sinon-chai'
helpers = require './spec_helper'

chai.use(sinonChai)
ResqueEnvironment = require '../lib/resque_environment'

describe 'ResqueEnvironment', ->
  beforeEach ->
    @resque = helpers.makeFakeResqueEnvironment()
    @redis = @resque.redis

  it 'sets necessary properties on the instance', ->
    @resque.port.should.eql 6379
    @resque.host.should.eql 'localhost'
    @resque.namespace.should.eql 'resque'
    @resque.dbnum.should.eql 0

  describe '#key', ->
    it 'returns the namespaced key', ->
      @resque.key('worker:test').should.eql 'resque:worker:test'

  describe '#processed', ->
    describe 'jobs have been processed', ->
      it 'returns the total number of jobs processed', (done) ->
        @redis.get = sinon.expectation.create('get').once().withArgs('resque:stat:processed').yields null, '100'
        @resque.processed (err, num) =>
          num.should.eql 100
          done(err)

    describe 'jobs have not been processed', ->
      it 'returns 0', (done) ->
        @redis.get = sinon.expectation.create('get').once().withArgs('resque:stat:processed').yields null, null
        @resque.processed (err, num) =>
          num.should.eql 0
          done(err)

  describe '#failed', ->
    describe 'jobs have been failed', ->
      it 'returns the total number of jobs failed', (done) ->
        @redis.get = sinon.expectation.create('get').once().withArgs('resque:stat:failed').yields null, '100'
        @resque.failed (err, num) =>
          num.should.eql 100
          done(err)

    describe 'jobs have not been failed', ->
      it 'returns 0', (done) ->
        @redis.get = sinon.expectation.create('get').once().withArgs('resque:stat:failed').yields null, null
        @resque.failed (err, num) =>
          num.should.eql 0
          done(err)

  describe '#queues', ->
    it 'returns an array of all the queues', (done) ->
      @redis.smembers = sinon.expectation.create('smembers').once().withArgs('resque:queues').yields null, ['mailer', 'chores', 'opengraph']
      @resque.queues (err, queues) =>
        queues.should.eql ['mailer', 'chores', 'opengraph']
        done(err)

  describe '#workers', ->
    it 'returns an array of all the workers', (done) ->
      @redis.smembers = sinon.expectation.create('smembers').once().withArgs('resque:workers').yields null, ['production-resque-1.host:1234:*', 'production-resque-1.host:5678:chores']
      @resque.workers (err, workers) =>
        workers.should.eql ['production-resque-1.host:1234:*', 'production-resque-1.host:5678:chores']
        done(err)
