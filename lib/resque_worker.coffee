module.exports = class ResqueWorker
  @fromString = (environment, string) ->
    [host, pid, queues] = string.split(':')
    new this(environment, host, pid, queues)

  constructor: (@environment, @host, pid, queues) ->
    @pid = parseInt(pid, 10)
    @queues = if typeof queues == 'string' then queues.split(',') else queues

  processed: (callback) =>
    @environment._stat "processed:#{@toString()}", callback

  failed: (callback) =>
    @environment._stat "failed:#{@toString()}", callback

  toString: =>
    "#{@host}:#{@pid}:#{@queues.join(',')}"
