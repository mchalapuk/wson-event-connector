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
    'CompositionEvent'
    'start'
    { bubbles: true, cancelable: true, data: 'deleted text', locale: 'C' }
    '[:CompositionEvent|start|#t|#t|deleted text|C|[:Window]|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
  [
    'CustomEvent'
    'chat'
    { bubbles: true, cancelable: true, detail: { contact: '@Jerry' } }
    '[:CustomEvent|chat|#t|#t|{contact:@Jerry}|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
  [
    'FocusEvent'
    'focus'
    { bubbles: true, cancelable: true, detail: 0 }
    '[:FocusEvent|focus|#t|#t|#0|[:Document]|[:Window]|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
  [
    'FontFaceEvent'
    'load'
    {
      bubbles: false, cancelable: false,
      family: 'Arial', src: 'file://Arial.ttf', usedSrc: 'file://Arial.ttf', style: 'normal'
      weight: 'bold', stretch: 'normal', unicodeRange: 'unset', variant: 'normal',
      featureSetting: null
    }
    '[:FontFaceEvent|load|#f|#f|Arial|file`i//Arial.ttf|file`i//Arial.ttf|normal|bold|normal|unset|normal|#n|[:HTMLBodyElement|/html`a1`e/body`a1`e]]',
  ]
  [
    'InputEvent'
    'beforeinput'
    { cancelable: true, data: '', isComposing: false }
    '[:InputEvent|beforeinput|#f|#t|#0|#|#f|[:Window]|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
  [
    'KeyboardEvent'
    'keyup'
    {
      detail: 0, ctrlKey: true, shiftKey: true, altKey: true, metaKey: true,
      modifierAltGraph: true, modifierCapsLock: true, modifierFn: true, modifierFnLock:true,
      modifierHyper: true, modifierNumLock: true, modifierScrollLock: true, modifierSuper: true,
      modifierSymbol: true, modifierSymbolLock: true,
      key: 'k', code: '75', location: 0, repeat: true, isComposing: false,
    }
    '[:KeyboardEvent|keyup|#f|#f|#0|#16383|k|75|#0|#t|#f|[:Window]|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
  [
    'MouseEvent'
    'click'
    {
      detail: 0, ctrlKey: true, shiftKey: true, altKey: true, metaKey: true,
      modifierAltGraph: true, modifierCapsLock: true, modifierFn: true, modifierFnLock:true,
      modifierHyper: true, modifierNumLock: true, modifierScrollLock: true, modifierSuper: true,
      modifierSymbol: true, modifierSymbolLock: true,
      screenX: 100, screenY: 200, clientX: 300, clientY: 400, button: 1, buttons: 3,
    }
    '[:MouseEvent|click|#f|#f|#0|#16383|#100|#200|#300|#400|#1|#3|[:Document]|[:Window]|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
  [
    'PointerEvent'
    'pointerdown'
    {
      altKey: true, screenX: 100, screenY: 200, clientX: 30, clientY: 40,
      pointerId: 4, width: 2, height: 2, pressure: 1, tangentialPressure: 1,
      tiltX: 20, tiltY: -15, twist: 4, pointerType: 'pen', isPrimary: true,
    }
    '[:PointerEvent|pointerdown|#f|#f|#0|#4|#100|#200|#30|#40|#0|#0|#4|#2|#2|#1|#1|#20|#-15|#4|pen|#t|[:Document]|[:Window]|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
  [
    'UIEvent'
    'swipe'
    { bubbles: true, cancelable: true, detail: 1 }
    '[:UIEvent|swipe|#t|#t|#1|[:Window]|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
  ]
  [
    'WheelEvent'
    'wheel'
    {
      detail: 0, ctrlKey: false, shiftKey: true, altKey: true, metaKey: true,
      modifierAltGraph: true, modifierCapsLock: true, modifierFn: true, modifierFnLock:true,
      modifierHyper: true, modifierNumLock: true, modifierScrollLock: true, modifierSuper: true,
      modifierSymbol: true, modifierSymbolLock: true,
      screenX: 1000, screenY: 2000, clientX: 333, clientY: 444, button: 1, buttons: 3,
      deltaX: 0, deltaY: -115, deltaZ: 0, deltaMode: 0,
    }
    '[:WheelEvent|wheel|#f|#f|#0|#16382|#1000|#2000|#333|#444|#1|#3|#0|#-115|#0|#0|[:Document]|[:Window]|[:HTMLBodyElement|/html`a1`e/body`a1`e]]'
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
          properties.view = window # UI events
          properties.relatedTarget = window.document # MouseEvent, FocusEvent
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

