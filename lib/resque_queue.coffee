module.exports = class ResqueQueue
  constructor: (@environment, @name) ->

  length: (callback) =>
    @environment.redis.llen @environment.key("queue:#{@name}"), callback

  jobs: (start, count, callback) =>
    end = start + count - 1
    end = -1 if count == -1

    @environment.redis.lrange @environment.key("queue:#{@name}"), start, end, (err, response) =>
      if err
        callback(err, response)
      else
        data = response.map JSON.parse
        callback(err, data)
