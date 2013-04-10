sinon = require 'sinon'
chai = require 'chai'
should = chai.should()
sinonChai = require 'sinon-chai'
helpers = require './spec_helper'

chai.use(sinonChai)
ResqueWorker = require '../lib/resque_worker'

describe 'ResqueWorker', ->
  beforeEach ->
    @resque = helpers.makeFakeResqueEnvironment()
    @redis = @resque.redis
    @worker = new ResqueWorker(@resque, 'localhost', 1234, 'mailer,chores')

  it 'sets public properties', ->
    @worker.host.should.eql 'localhost'
    @worker.pid.should.eql 1234
    @worker.queues.should.eql ['mailer', 'chores']

  describe 'constructor', ->
    it 'allows queues to be passed as an array of strings', ->
      worker = new ResqueWorker(@resque, 'localhost', 1234, ['mailer', 'chores'])
      worker.queues.should.eql ['mailer', 'chores']

  describe 'fromString', ->
    it 'creates a worker from an environment and a worker string', ->
      worker = ResqueWorker.fromString(@resque, 'localhost:1234:mailer,chores')
      worker.environment.should.equal @resque
      worker.host.should.eql 'localhost'
      worker.pid.should.eql 1234
      worker.queues.should.eql ['mailer', 'chores']

  describe '#processed', ->
    describe 'when jobs have been processed by the worker', =>
      it 'returns the number of jobs processed by the worker', (done) ->
        @redis.get = sinon.expectation.create('get').once().withArgs('resque:stat:processed:localhost:1234:mailer,chores').yields null, '100'
        @worker.processed (err, num) =>
          num.should.eql 100
          done(err)

    describe 'when no jobs have been processed by the worker', (done) ->
      it 'returns 0', (done) ->
        @redis.get = sinon.expectation.create('get').once().withArgs('resque:stat:processed:localhost:1234:mailer,chores').yields null, null
        @worker.processed (err, num) =>
          num.should.eql 0
          done(err)

  describe '#failed', ->
    describe 'when jobs have been failed by the worker', =>
      it 'returns the number of jobs failed by the worker', (done) ->
        @redis.get = sinon.expectation.create('get').once().withArgs('resque:stat:failed:localhost:1234:mailer,chores').yields null, '100'
        @worker.failed (err, num) =>
          num.should.eql 100
          done(err)

    describe 'when no jobs have been failed by the worker', (done) ->
      it 'returns 0', (done) ->
        @redis.get = sinon.expectation.create('get').once().withArgs('resque:stat:failed:localhost:1234:mailer,chores').yields null, null
        @worker.failed (err, num) =>
          num.should.eql 0
          done(err)

  describe '#processing', ->
    describe 'when the worker is processing a job', ->
      it 'returns the job being processed', (done) ->
        done()

    describe 'when the worker is not processing a job', ->
      it 'returns null', (done) ->
        done()

  describe '#toString', ->
    it 'returns a string representation of the worker', ->
      @worker.toString().should.eql 'localhost:1234:mailer,chores'
