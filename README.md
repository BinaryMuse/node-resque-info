node-resque-info is a Node.js library that you can use to get information about a Resque instance.

(Note: project is under construction)

Installation
============

    npm install resque-info

Compatibility
=============

node-resque-info is currently targeted at Resque 1.x. Version 2.0 support is planned after Resque 2.0 is released.

Usage
=====

node-resque-info provides a set of classes that can be used to get information about specific pieces of your Resque infrastructure; it also provides a `ResqueInfo` class that aggregates this info into a single value.

All API methods that take a `callback` parameter is in the traditional Node.js `function(error, data)` style.

`ResqueEnvironment`
-------------------

`ResqueEnvironment` specifies information about your Resque environment, including the redis host, port, and namespace prefix that your Resque instance runs.

```javascript
var resqueInfo = require('resque-info');
var redisPort = 6379;
var redisHost = 'localhost';
var resqueNamespace = 'resque'; // Resque's default namespace
var env = new resqueInfo.ResqueEnvironment(redisPort, redisHost, resqueNamesapce);
```

### Methods

 * `#queues(callback)` - Get an array of `ResqueQueue`s that represent all the current Resque queues.

`ResqueQueue`
-------------

`ResqueQueue` represents a queue in Resque.

```javascript
var queue = new resqueInfo.ResqueQueue(resqueEnvironment, queueName);
```

### Methods

 * `#length(callback)` - Get the current length of the queue.
 * `#jobs([start], [end], callback)` - Get an array of `ResqueJob`s that represent jobs in the queue. If only `callback` is provided, `start` and `end` are assumed to be `0` and `-1`, respectively. If only `end` and `callback` are provided, `start` is assumed to be `0`. To return all jobs, `start` and `end` should be `0` and `-1`, respectively.
