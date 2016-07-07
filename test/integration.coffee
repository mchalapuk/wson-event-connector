should = require 'should'
mocha = require 'mocha'
_ = require 'underscore'

jsdom = require 'jsdom'
declareMissingEvents = require './event-stubs.coffee'
WSON = require 'wson'

delete require.cache[ require.resolve '../' ]
eventConnectors = require '..'
domConnectors = require 'wson-dom-connector'

testParams = [
  [
    'Event'
    'generic'
    {
      bubbles: false
      cancelable: false
    }
    '[:Event|generic|#f|#f|[:HTMLBodyElement|/html`a1`e/body`a1`e]]' ]
  [
    'AnimationEvent'
    'test'
    {
      bubbles: false
      cancelable: false
      animationName: 'testAnim'
      elapsedTime: 100
      pseudoElement: 'pseudo'
    }
    '[:AnimationEvent|test|#f|#f|testAnim|#100|pseudo|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
]


describe "WSON with all Event and DOM connectors", ->
  window = null
  body = null

  testedWSON = null

  beforeEach ->
    window = declareMissingEvents jsdom.jsdom().defaultView
    body = window.document.body
    testedWSON = new WSON connectors: _.extend eventConnectors(window), domConnectors(window)
  afterEach ->
    window.close()

  describe ".stringify", ->
    for params in testParams
      do (params) ->
        [eventName, eventType, properties, expectedString] = params

        it "should serialize #{eventName} to #{expectedString}", ->
          event = new window[eventName] eventType, properties
          serialized = null
          body.addEventListener eventType, -> serialized = testedWSON.stringify event
          body.dispatchEvent event
          serialized.should.equal expectedString

  describe '.parse', ->
    for params in testParams
      do (params) ->
        [eventName, eventType, properties, expectedString] = params

        it "should parse #{expectedString} to #{eventName} instance", ->
          deserialized = testedWSON.parse expectedString
          deserialized.type.should.be.exactly eventType
          deserialized[key].should.be.equal properties[key] for key in Object.keys properties
          deserialized.parsedTarget.should.be.exactly body

