node-resque-info
================

[![Build Status](https://travis-ci.org/BinaryMuse/node-resque-info.png?branch=master)](https://travis-ci.org/BinaryMuse/node-resque-info)

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
var redisDbNum = 0
var resqueNamespace = 'resque'; // Resque's default namespace
var env = new resqueInfo.ResqueEnvironment(resqueNamespace, redisPort, redisHost, redisDbNum);
```

All arguments to the constructor are optional; the defaults are as follows:

 * `namespace` - `'resque'`, the default namespace set by the Resque gem
 * `port` - `6379`, the default Redis port
 * `host` - `'localhost'`
 * `dbnum` - `0`

### Methods

 * `#processed(callback)` - Get the total number of jobs processed by Resque.
 * `#failed(callback)` - Get the total number of failed jobs.
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
 * `#jobs(start, count, callback)` - Get an array of objects that represent jobs in the queue. To return all jobs, `start` and `count` should be `0` and `-1`, respectively. Returns an empty array if there are no jobs in the queue.

`ResqueWorker`
--------------

`ResqueWorker` represents a running Resque worker. You can get an array of `ResqueWorker`s from your current environment with `ResqueEnvironment#workers`.

```javascript
var worker = new resqueInfo.ResqueWorker(resqueEnvironment, workerHost, workerPid, workerQueues);
```

`workerQueues` can either be a string representing a list of queues to process (`"mailer,chores"`), or an array of strings, where each string is a queue (`["mailer", "chores"]`).

### Properties

 * `host` - The host the worker is workig on.
 * `pid` - The PID of the worker process.
 * `queues` - An array of the queues this worker is processing, e.g. `['mailer', 'chores']`.

### Class Methods

 * `.fromString(resqueEnvironment, string)` - Create a `ResqueWorker` instance from a `ResqueEnvironment` and a string representation of a worker, formatted as: `host:pid:queues`.

### Methods

 * `#started(callback)` - Get the `Date` this worker was started.
 * `#processed(callback)` - Get the number of jobs this worker has processed.
 * `#failed(callback)` - Get the number of jobs this worker has failed to process.
 * `#processing(callback)` - Get an object representing the job being currently processed, or `null` if none.
 * `#toString()` - Get a string representation of the worker, formatted as: `host:pid:queues`

Jobs
----

Resque jobs are represented by plain JavaScript objects.

### Properties

All jobs contain the following properties:

 * `queue` - The name of the queue the job was queued on.
 * `payload` - An object representing the job's payload:
   * `class` - The name of the class the Job was queued from.
   * `args` - An array of arguments passed to the job.

If you use plugins or gems to add additional information to your Resque job paylods, those properties will also exist on the `payload` property.

Jobs that have yet to run or are being processed have the following properties:

 * `run_at` - A string timestamp of the date a worker started processing the job, or `null` if the job has yet to be processed.

Failed jobs have the following properties:

 * `failed_at` - A string timestamp of the date that the job failed, or `null` if the job has yet to fail.
 * `exception` - If the job has failed, the name of the exception class that triggered the failure. `null` if the job has not failed.
 * `error` - An object representation of the error.
 * `backtrace` - An array of strings representing the backtrace of the error.
 * `worker` - A string representation of the worker that processed the job, in the format: `host:pid:queues`.

### Methods

 * `#status()` - Either `'waiting'`, `'processing'`, or `'failed'`.
