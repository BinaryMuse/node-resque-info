module.exports = class ResqueWorker
  @fromString = (environment, string) ->
    [host, pid, queues] = string.split(':')
    new this(environment, host, pid, queues)

  constructor: (@environment, @host, pid, queues) ->
    @pid = parseInt(pid, 10)
    @queues = if typeof queues == 'string' then queues.split(',') else queues

  processed: (callback) =>
    @_stat "processed:#{@toString()}", callback

  failed: (callback) =>
    @_stat "failed:#{@toString()}", callback

  _stat: (suffix, callback) =>
    key = @environment.key "stat:#{suffix}"
    @environment.redis.get key, (err, response) ->
      if err
        callback(err, response)
      else if response == null
        callback(err, 0)
      else
        callback(err, parseInt(response, 10))

  toString: =>
    "#{@host}:#{@pid}:#{@queues.join(',')}"
