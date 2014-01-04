'use strict'

print   = require('debug')('ganglia')
router  = require('routington')()
_       = require 'underscore'
Bacon   = require 'baconjs'
kinesis = require 'kinesis'

centralDispatch = undefined
source = {}
sink = {}

ganglia =
  define: (path = '', label = 'other') ->
    [node] = router.define(path)
    node.lebel ?= label
    ganglia[label] ?= new Bacon.Bus()
    ganglia

  pull: (options = {region: 'us-east-1'}, interval = 30) ->
    return ganglia if centralDispatch?

    # initiate pulling
    do f = ->
        kinesis.listStreams options, (error, streams = []) ->
            centralDispatch.push new Bacon.Error error if error?

            _.chain(streams)
            .filter (name) ->
              !(source[name]?)
            .map (name) ->
              match = router.match name
              match?.name = name
              match
            .compact()
            .each ({name, param, node: {label}}) ->
              source[name] = stream = ganglia.createReadStream(name, options).map (value) ->
                {label, param, value}
              ganglia[label]?.plug stream

    setInterval f, interval * 1000
    ganglia

  createReadStream: (name = '', options = {region: 'us-east-1'}) ->
    return source[name] if source[name]?
    es = kinesis.createReadStream name, options
    source[name] = Bacon.fromEventTarget(es, 'data')
    .map (buffer) ->
        str = buffer.toString()
        obj = undefined
        try
            obj = JSON.parse str
        catch e
            print 'bad JSON'
            print str
        return obj or str
    .filter(_.isObject)

  createWriteStream: (name = '', options = {region: 'us-east-1'}) ->
    return sink[name] if sink[name]?
    es = kinesis.createWriteStream name, options
    bus = new Bacon.Bus()
    bus.onValue (data) ->
        if _.isString data
            es.write data
        else
            try
                es.write JSON.stringify data
            catch e
                console.log 'error while stringifying data', e

    sink[name] = bus

module.exports = ganglia
