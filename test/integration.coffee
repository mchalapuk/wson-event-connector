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
    { bubbles: true, cancelable: true }
    '[:Event|generic|#t|#t|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
  [
    'AnimationEvent'
    'test'
    { bubbles: true, animationName: 'testAnim', elapsedTime: 100, pseudoElement: 'pseudo' }
    '[:AnimationEvent|test|#t|#f|testAnim|#100|pseudo|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
  [
    'BeforeUnloadEvent'
    'yay!'
    {}
    '[:BeforeUnloadEvent|yay!|#f|#f|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
  [
    'ClipboardEvent'
    'copy'
    { cancelable: true, data: 'https://github.com/' }
    '[:ClipboardEvent|copy|#f|#t|text/plain|https`i//github.com/|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
  [
    'CloseEvent'
    'close'
    { bubbles: true, cancelable: true, code: 1000, reason: '', wasClean: true }
    '[:CloseEvent|close|#t|#t|#1000|#|#t|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
  [
    'CustomEvent'
    'chat'
    { bubbles: true, cancelable: true, detail: '@Jerry' }
    '[:CustomEvent|chat|#t|#t|@Jerry|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
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

        it "should serialize #{eventName}", ->
          event = new window[eventName] eventType, properties
          serialized = null
          body.addEventListener eventType, -> serialized = testedWSON.stringify event
          body.dispatchEvent event
          serialized.should.equal expectedString

  describe '.parse', ->
    for params in testParams
      do (params) ->
        [eventName, eventType, properties, expectedString] = params

        it "should parse #{expectedString}", ->
          event = new window[eventName] eventType, properties
          deserialized = testedWSON.parse expectedString
          deserialized.type.should.be.exactly eventType
          deserialized.parsedTarget.should.be.exactly body

