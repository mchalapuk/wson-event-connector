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
    { bubbles: true, cancelable: true, detail: { contact: '@Jerry' } }
    '[:CustomEvent|chat|#t|#t|{contact:@Jerry}|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
  [
    'UIEvent'
    'swipe'
    { bubbles: true, cancelable: true, detail: 1 }
    '[:UIEvent|swipe|#t|#t|#1|[:Window]|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
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

        event = null

        beforeEach ->
          properties.view = window # for UI events
          event = new window[eventName] eventType, properties

        it "should serialize #{eventName}", ->
          serialized = null
          body.addEventListener eventType, -> serialized = testedWSON.stringify event
          body.dispatchEvent event
          serialized.should.equal expectedString

  describe '.parse', ->
    for params in testParams
      do (params) ->
        [eventName, eventType, properties, expectedString] = params

        it "should parse #{expectedString}", ->
          deserialized = testedWSON.parse expectedString
          deserialized.type.should.be.exactly eventType
          deserialized.parsedTarget.should.be.exactly body
          (deserialized.view is window).should.be.true if deserialized instanceof window.UIEvent
