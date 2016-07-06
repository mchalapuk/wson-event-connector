mocha = require 'mocha'
should = require 'should'

jsdom = require 'jsdom'

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
    testedConnector = connectors(window).Event
    event = new window.Event 'generic',
        bubbles: false,
        cancelable: false,
  after ->
    window.close()

  describe '.by', ->
    it 'should be events\'s constructor', ->
      testedConnector.by.should.be.exactly window.Event

  describe '.split', ->
    it 'should return stringified event', ->
      splitted = null
      document.body.addEventListener 'generic', ->
        splitted = testedConnector.split event
      document.body.dispatchEvent event
      splitted.should.be.eql [ 'generic', false, false, document.body ]

  describe '.create', ->
    it 'should return event equal to the one serialized', ->
      splitted = null
      document.body.addEventListener 'generic', ->
        splitted = testedConnector.split event
      document.body.dispatchEvent event

      created = testedConnector.create splitted
      [ 'type', 'cancelable', 'bubbles' ].forEach (key)-> created[key].should.equal event[key]
      created.parsedTarget.should.be.exactly document.body

