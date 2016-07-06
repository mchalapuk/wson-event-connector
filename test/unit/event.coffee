mocha = require 'mocha'
should = require 'should'

jsdom = require 'jsdom'
_ = require 'underscore'

delete require.cache[ require.resolve '../..' ]
connectors = require '../..'

describe 'connector.Event', ->
  document = null
  window = null
  testedConnector = null
  event = null

  before ->
    document = jsdom.jsdom()
    window = document.defaultView
    testedConnector = new connectors(window).Event
    event = new window.Event 'generic',
        bubbles: false,
        cancelable: false,
        currentTarget: window,
        target: document.body

  describe '.by', ->

    it 'should be events\'s constructor', ->
      testedConnector.by.should.be.exactly window.Event

  describe '.split', ->

    it 'should return stringified event', ->
      testedConnector.split(event).should.be.eql [ 'generic', false, false, window, document.body ]

  describe '.create', ->

    it 'should return event equalivent to one serialized', ->
      serialized = testedConnector.split event
      unserialized = testedConnector.create serialized
      [ 'type', 'cancelable', 'bubbles', 'currentTarget', 'target' ].forEach (key)->
        unserialized[key].should.equal event[key]

