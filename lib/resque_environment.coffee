redis = require 'redis'

module.exports = class ResqueEnvironment
  constructor: (@namespace = 'resque', @port = 6379, @host = 'localhost', @dbnum = 0) ->
    # do nothing

  connect: =>
    return if @connected
    @connected = true
    @_createClient()

  key: (key) =>
    "#{@namespace}:#{key}"

  queues: (callback) =>
    @redis.smembers @key('queues'), callback

  workers: (callback) =>
    @redis.smembers @key('workers'), callback

  _createClient: =>
    @redis = redis.createClient(@port, @host)
    @redis.select(@dbnum) if @dbnum != 0
