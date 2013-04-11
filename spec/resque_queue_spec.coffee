sinon = require 'sinon'
chai = require 'chai'
should = chai.should()
sinonChai = require 'sinon-chai'
helpers = require './spec_helper'

chai.use(sinonChai)
ResqueQueue = require '../lib/resque_queue'

describe 'ResqueQueue', ->
  beforeEach ->
    @resque = helpers.makeFakeResqueEnvironment()
    @redis = @resque.redis
    @queue = new ResqueQueue(@resque, 'mailer')

  describe '#length', ->
    it 'returns the number of jobs on the queue', (done) ->
      @redis.llen = sinon.expectation.create('llen').once().withArgs('resque:queue:mailer').yields null, 5
      @queue.length (err, length) =>
        length.should.eql 5
        done(err)

  describe '#jobs', ->
    describe 'when there are jobs in the queue', ->
      beforeEach ->
        @jobStrings = [
          "{\"job\": 1}"
          "{\"job\": 2}"
          "{\"job\": 3}"
          "{\"job\": 4}"
          "{\"job\": 5}"
          "{\"job\": 6}"
          "{\"job\": 7}"
          "{\"job\": 8}"
          "{\"job\": 9}"
          "{\"job\": 10}"
          "{\"job\": 11}"
        ]

      it 'returns all the jobs in the queue', (done) ->
        @redis.lrange = sinon.expectation.create('lrange').once().withArgs('resque:queue:mailer', 0, -1).yields null, @jobStrings
        @queue.jobs 0, -1, (err, jobs) =>
          jobs.should.deep.eql @jobStrings.map JSON.parse
          done(err)

      it 'returns the first x jobs in the queue', (done) ->
        @redis.lrange = sinon.expectation.create('lrange').once().withArgs('resque:queue:mailer', 0, 4).yields null, @jobStrings[0..4]
        @queue.jobs 0, 5, (err, jobs) =>
          jobs.should.deep.eql @jobStrings[0..4].map JSON.parse
          done(err)

      it 'returns a subset of jobs in the queue', (done) ->
        @redis.lrange = sinon.expectation.create('lrange').once().withArgs('resque:queue:mailer', 5, 9).yields null, @jobStrings[5..9]
        @queue.jobs 5, 5, (err, jobs) =>
          jobs.should.deep.eql @jobStrings[5..9].map JSON.parse
          done(err)

    describe 'when there are no jobs in the queue', ->
      it 'returns an empty array', (done) ->
        @redis.lrange = sinon.expectation.create('lrange').once().yields null, []
        @queue.jobs 0, -1, (err, jobs) =>
          jobs.should.eql []
          done(err)
