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
    it 'returns all the jobs in the queue', (done) ->
      done()

    it 'returns the first x jobs in the queue', (done) ->
      done()

    it 'returns a subset of jobs in the queue', (done) ->
      done()
