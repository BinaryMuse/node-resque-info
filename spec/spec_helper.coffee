ResqueEnvironment = require '../lib/resque_environment'

module.exports =
  makeFakeResqueEnvironment: (namespace = 'resque') =>
    fakeRedis = {}
    resque = new ResqueEnvironment(namespace, 6379, 'localhost', 0)
    resque.redis = fakeRedis
    resque.connected = true
    resque
