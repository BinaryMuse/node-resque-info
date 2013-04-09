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
 * `#workers(callback)` - Get an array of `ResqueWorker`s that represent all the current Resque workers.

`ResqueQueue`
-------------

`ResqueQueue` represents a queue in Resque. You can get an array of `ResqueQueue`s from your current environment with `ResqueEnvironment#queues`.

```javascript
var queue = new resqueInfo.ResqueQueue(resqueEnvironment, queueName);
```

### Methods

 * `#length(callback)` - Get the current length of the queue.
 * `#jobs([start], [end], callback)` - Get an array of `ResqueJob`s that represent jobs in the queue. If only `callback` is provided, `start` and `end` are assumed to be `0` and `-1`, respectively. If only `end` and `callback` are provided, `start` is assumed to be `0`. To return all jobs, `start` and `end` should be `0` and `-1`, respectively.

`ResqueWorker`
--------------

`ResqueWorker` represents a running Resque worker. You can get an array of `ResqueWorker`s from your current environment with `ResqueEnvironment#workers`.

```javascript
var worker = new resqueInfo.ResqueWorker(resqueEnvironment, workerHost, workerPid, workerQueues);
```

`workerQueues` can either be a string representing a list of queues to process (`"mailer,chores"`), or an array of strings, where each string is a queue (`["mailer", "chores"]`).

### Methods

 * `#processed(callback)` - Get the number of jobs this worker has processed.
 * `#failed(callback)` - Get the number of jobs this worker has failed to process.
 * `#processing(callback)` - Get a `ResqueJob` representing the job being currently processed, or `null` if none.

`ResqueJob`
-----------

`ResqueJob` represents a queued Resque job. It differs from the other classes in that it does not require a `ResqueEnvironment` instance to be created; it is simply a set of data.

```javascript
var job = new resqueInfo.ResqueJob(
```

### Properties

 * `queue` - The name of the queue the job was queued on.
 * `run_at` - A `Date` representing the date a worker started processing the job, or `null` if the job has yet to be processed.
 * `payload` - An object representing the job's playload:
   * `class` - The name of the class the Job was queued from.
   * `args` - An array of arguments passed to the job.

If you use plugins or gems to add additional information to your Resque job paylods, those properties will also exist on the `playload` property.
