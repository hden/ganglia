ganglia
=======

Relay points for reactive applications

[![Kinesis](http://img.youtube.com/vi/MbEfiX4sMXc/0.jpg)](http://www.youtube.com/watch?v=MbEfiX4sMXc)

* Amazon [Kinesis](http://aws.amazon.com/kinesis/)
* [Functional Reactive Programming](http://en.wikipedia.org/wiki/Functional_reactive_programming) via [Bacon.js](https://github.com/baconjs/bacon.js)
* [Trie](http://en.wikipedia.org/wiki/Trie)-based routing via [routinton](https://github.com/jonathanong/routington)

Installation
------------

    $ npm install --save ganglia

Routing
-------

    var assert = require('assert');
    var app    = require('ganglia');

    app
      .define(route, label)
      .define('/action/:id', 'customActions')

    var stream = app.customActions;

    // Let's say we've just published {"foo": "bar"} to a stream named /action/123

    stream.onValue(function (data) {
      assert(data.label === 'customActions');
      assert(data.param.id === '123');
      assert(data.value.foo === 'bar')
    });

* `route`, is a definition of a route and is an extension of Express' routing syntax.
    * See [routinton](https://github.com/jonathanong/routington) for detail

* `stream`, is a event-stream of [Bacon.js](https://github.com/baconjs/bacon.js)
