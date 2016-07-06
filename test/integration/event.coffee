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
      Window: domConnectors(window, document).Window,
      HTMLBodyElement: domConnectors(window, document).HTMLBodyElement
    event = new window.Event 'generic',
        bubbles: false,
        cancelable: false,
        currentTarget: window,
        target: document.body

  describe '.stringify', ->
     it 'should serialize an event', ->
      serialized = testedWSON.stringify event
      serialized.should.equal '[:Event|generic,#f,#f,[:Window],[:HTMLBodyElement|/html`a1`e/body`a1`e]]'

  describe '.parse', ->
    it 'should return instance eqivalent to the one passed to .stringify', ->
      serialized = testedWSON.stringify event
      deserialized = testedWSON.parse serialized
      ['type', 'bubbles', 'cancelable', 'currentTarget', 'target'].forEach (key)->
        deserialized[key].should.equal event[key]

    it 'should be able to parse event stringified in another window', ->
        serialized = testedWSON.stringify event

        anotherDocument = jsdom.jsdom document.body.outerHTML
        anotherWindow = anotherDocument.defaultView
        anotherWSON = new WSON connectors:
          Event: eventConnectors(anotherWindow).Event,
          Window: domConnectors(anotherWindow, anotherDocument).Window,
          HTMLBodyElement: domConnectors(anotherWindow, anotherDocument).HTMLBodyElement

        deserialized = anotherWSON.parse serialized
        ['type', 'bubbles', 'cancelable'].forEach (key)-> deserialized[key].should.equal event[key]
        deserialized.currentTarget.should.be.exactly anotherWindow
        deserialized.target.should.be.exactly anotherDocument.body

