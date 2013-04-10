redis = require 'redis'
ResqueQueue = require './resque_queue'
ResqueWorker = require './resque_worker'

module.exports = class ResqueEnvironment
  constructor: (@namespace = 'resque', @port = 6379, @host = 'localhost', @dbnum = 0) ->
    # do nothing

  connect: =>
    return if @connected
    @connected = true
    @_createClient()

  key: (key) =>
    "#{@namespace}:#{key}"

  processed: (callback) =>
    @_stat "processed", callback

  failed: (callback) =>
    @_stat "failed", callback

  queues: (callback) =>
    @redis.smembers @key('queues'), (err, queueNames) =>
      if err
        callback(err, queueNames)
      else
        queues = queueNames.map (name) => new ResqueQueue(this, name)
        callback(err, queues)

  workers: (callback) =>
    @redis.smembers @key('workers'), (err, workerNames) =>
      if err
        callback(err, workerNames)
      else
        workers = workerNames.map (name) => ResqueWorker.fromString(this, name)
        callback(err, workers)

  _stat: (suffix, callback) =>
    key = @key "stat:#{suffix}"
    @redis.get key, (err, response) ->
      if err
        callback(err, response)
      else if response == null
        callback(err, 0)
      else
        callback(err, parseInt(response, 10))

  _createClient: =>
    @redis = redis.createClient(@port, @host)
    @redis.select(@dbnum) if @dbnum != 0
