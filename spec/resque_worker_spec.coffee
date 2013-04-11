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

  describe '#started', ->
    describe 'when the worker is running', ->
      it 'returns the Date the worker was started', (done) ->
        dateString = '2013-04-10 23:43:39 +0000'
        @redis.get = sinon.expectation.create('get').once().withArgs('resque:worker:localhost:1234:mailer,chores:started').yields null, dateString
        @worker.started (err, date) =>
          date.should.eql new Date(dateString)
          done(err)

    describe 'when the worker is not running', ->
      it 'returns null', (done) ->
        @redis.get = sinon.expectation.create('get').once().withArgs('resque:worker:localhost:1234:mailer,chores:started').yields null, null
        @worker.started (err, date) =>
          should.not.exist(date)
          done(err)

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
        expectedJob =
          queue: 'apns'
          run_at: '2013/04/11 16:53:25 UTC'
          payload:
            class: 'ApnsNotifier'
            args: [119]
            caller_nid: 'Learnist-production-29b95c3404d9683273b7aba95e9d0ac047530250-WEB-bf9a54832ba21e2c2856'

        jobString = "{\"queue\":\"apns\",\"run_at\":\"2013/04/11 16:53:25 UTC\",\"payload\":{\"class\":\"ApnsNotifier\",\"args\":[119],\"caller_nid\":\"Learnist-production-29b95c3404d9683273b7aba95e9d0ac047530250-WEB-bf9a54832ba21e2c2856\"}}"

        @redis.get = sinon.expectation.create('get').once().withArgs("resque:worker:localhost:1234:mailer,chores").yields null, jobString
        @worker.processing (err, job) =>
          job.should.deep.eql expectedJob
          done(err)

    describe 'when the worker is not processing a job', ->
      it 'returns null', (done) ->
        @redis.get = sinon.expectation.create('get').once().withArgs("resque:worker:localhost:1234:mailer,chores").yields null, null
        @worker.processing (err, job) =>
          should.not.exist(job)
          done(err)

  describe '#toString', ->
    it 'returns a string representation of the worker', ->
      @worker.toString().should.eql 'localhost:1234:mailer,chores'
