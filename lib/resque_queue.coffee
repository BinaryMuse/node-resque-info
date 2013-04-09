module.exports = class ResqueQueue
  constructor: (@environment, @name) ->

  length: (callback) =>
    @environment.redis.llen @environment.key("queue:#{@name}"), callback
