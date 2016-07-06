should = require 'should'
mocha = require 'mocha'

jsdom = require 'jsdom'
WSON = require 'wson'

delete require.cache[ require.resolve '../..' ]
eventConnectors = require '../..'
domConnectors = require 'wson-dom-connector'

describe 'WSON with Event connector', ->
  document = null
  window = null
  testedWSON = null
  event = null

  before ->
    document = jsdom.jsdom()
    window = document.defaultView
    testedWSON = new WSON connectors:
      Event: eventConnectors(window).Event,
      HTMLBodyElement: domConnectors(window, document).HTMLBodyElement
    event = new window.Event 'generic',
        bubbles: false,
        cancelable: false,
  after ->
    window.close()

  describe '.stringify', ->
    it 'should serialize an event', ->
      serialized = null
      document.body.addEventListener 'generic', -> serialized = testedWSON.stringify event
      document.body.dispatchEvent event
      serialized.should.equal '[:Event|generic|#f|#f|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'

  describe '.parse', ->
    it 'should return instance equal to the one passed to .stringify', ->
      serialized = null
      document.body.addEventListener 'generic', -> serialized = testedWSON.stringify event
      document.body.dispatchEvent event

      deserialized = testedWSON.parse serialized
      ['type', 'bubbles', 'cancelable'].forEach (key)-> deserialized[key].should.equal event[key]
      deserialized.parsedTarget.should.be.exactly document.body

    it 'should be able to parse event stringified in another window', ->
      serialized = null
      document.body.addEventListener 'generic', -> serialized = testedWSON.stringify event
      document.body.dispatchEvent event

      anotherDocument = jsdom.jsdom document.body.outerHTML
      anotherWindow = anotherDocument.defaultView
      anotherWSON = new WSON connectors:
        Event: eventConnectors(anotherWindow).Event,
        HTMLBodyElement: domConnectors(anotherWindow, anotherDocument).HTMLBodyElement

      deserialized = anotherWSON.parse serialized
      ['type', 'bubbles', 'cancelable'].forEach (key)-> deserialized[key].should.equal event[key]
      deserialized.parsedTarget.should.be.exactly anotherDocument.body

