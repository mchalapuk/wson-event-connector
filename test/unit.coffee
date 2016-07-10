mocha = require 'mocha'
should = require 'should'

jsdom = require 'jsdom'
_ = require 'underscore'
declareMissingEvents = require './event-stubs.coffee'

delete require.cache[ require.resolve '../' ]
connectors = require '..'

# It started very innocent but grew to be quite a monster...
# This file contains unit tests of all classes implemented by this module.

window = null
before -> window = declareMissingEvents jsdom.jsdom().defaultView
after -> window.close()

# A map from name to check functions (defined at the bottom of this file).
check = {}


# UNIT TEST TEMPLATE


describeEventUnitTests = (eventName, eventType, getDynamicParams)->
  init = null
  expectedSplit = null
  checks = null

  testedConnector = null
  event = null

  beforeEach ->
    [ init, expectedSplit, checks ] = getDynamicParams()
    testedConnector = connectors[eventName] window[eventName]
    event = new window[eventName] eventType, init

  describe ".by", ->
    it "should be #{eventName}\'s constructor", ->
      testedConnector.by.should.be.exactly window[eventName]

  describe ".split", ->
    it "should return proper split", ->
      testedConnector.split(event).should.be.eql expectedSplit

  describe ".create", ->
    it "should return instance of #{eventName}", ->
      created = testedConnector.create expectedSplit
      created.type.should.equal eventType
      created.constructor.should.be.exactly window[eventName]
      check[name] init, created for name in checks


# EXCEPTIONAL CASES


# connector.TouchEvent must be tested separately
# because of TouchEvent's complicated initialization.
describe "connector.TouchEvent", ->
  eventName = 'TouchEvent'
  eventType = 'touch'
  checks = [ 'touchLists', 'properties' ]

  init = null
  expectedSplit = null

  beforeEach ->
    touch = new window.Touch {
      identifier: 1, target: window.document.body,
      clientX: 400, clientY: 500, screenX: 600, screenY: 700, pageX: 10, pageY: 20,
      radiusX: 5, radiusY: 4, rotationAngle: 9, force: 1,
    }
    init = {
      touches: [ touch ], targetTouches: [], changedTouches: [ touch ],
      altKey: true, metaKey: false, ctrlKey: true, shiftKey: false,
    }
    splitTouch = [ 1, window.document.body, 400, 500, 600, 700, 10, 20, 5, 4, 9, 1 ]
    expectedSplit = [
      eventType, false, false, 0, [ touch ], [], [ touch ], true, false, true, false, null, null
    ]

  describeEventUnitTests eventName, eventType, -> [ init, expectedSplit, checks ]


# Touch must be tested separately is not an event.
describe "connector.Touch", ->
  className = 'Touch'

  init = null
  expectedSplit = null

  testedConnector = null
  touch = null

  beforeEach ->
    init = {
      identifier: 1, target: window.document.body,
      clientX: 400, clientY: 500, screenX: 600, screenY: 700, pageX: 10, pageY: 20,
      radiusX: 5, radiusY: 4, rotationAngle: 9, force: 1,
    }
    expectedSplit = [
      1, window.document.body, 400, 500, 600, 700, 10, 20, 5, 4, 9, 1
    ]
    touch = new window[className] init

    testedConnector = connectors[className] window[className]

  describe ".by", ->
    it "should be #{className}\'s constructor", ->
      testedConnector.by.should.be.exactly window[className]

  describe ".split", ->
    it "should return proper split", ->
      testedConnector.split(touch).should.be.eql expectedSplit

  describe ".create", ->
    it "should return instance of #{className}", ->
      created = testedConnector.create expectedSplit
      created.constructor.should.be.exactly window[className]
      check.properties init, created


# EVENT CONNECTOR UNIT TESTS


testParams = [
  [
    'Event'
    'generic'
    { bubbles: false, cancelable: false }
    [ 'generic', false, false, null ]
    [ 'properties' ]
  ]
  [
    'AnimationEvent'
    'test'
    {
      bubbles: false, cancelable: true
      animationName: 'testAnim', elapsedTime: 100, pseudoElement: 'pseudo'
    }
    [ 'test', false, true, 'testAnim', 100, 'pseudo', null ]
    [ 'properties' ]
  ]
  [
    'BeforeUnloadEvent'
    'beforeunload'
    { bubbles: false, cancelable: true  }
    [ 'beforeunload', false, true, null ]
    [ 'properties' ]
  ]
  [
    'ClipboardEvent'
    'copy'
    { bubbles: true, cancelable: true, dataFormat: 'text/plain', data: 'https://github.com/' }
    [ 'copy', true, true, 'text/plain', 'https://github.com/', null ]
    [ 'clipboardData' ]
  ]
  [
    'CloseEvent'
    'close'
    { bubbles: false, cancelable: false, code: 1000, reason: '', wasClean: true }
    [ 'close', false, false, 1000, '', true, null ]
    [ 'properties' ]
  ]
  [
    'CompositionEvent'
    'start'
    { bubbles: true, cancelable: true, data: 'deleted text', locale: 'C' }
    [ 'start', true, true, 'deleted text', 'C', null, null ]
    [ 'properties' ]
  ]
  [
    'CustomEvent'
    'chat'
    { bubbles: false, cancelable: false, detail: { contact: '@Matilda' } }
    [ 'chat', false, false, { contact: '@Matilda' }, null ]
    [ 'properties' ]
  ]
  [
    'FocusEvent'
    'focus'
    { bubbles: true, cancelable: true, detail: 0 }
    [ 'focus', true, true, 0, null, null, null ]
    [ 'properties' ]
  ]
  [
    'FontFaceEvent'
    'load'
    {
      bubbles: false, cancelable: false,
      family: 'Arial', src: 'file://Arial.ttf', usedSrc: 'file://Arial.ttf', style: 'normal'
      weight: 'bold', stretch: 'normal', unicodeRange: 'unset', variant: 'normal',
      featureSetting: 'mysetting on'
    }
    [
      'load', false, false,
      'Arial', 'file://Arial.ttf', 'file://Arial.ttf', 'normal',
      'bold', 'normal', 'unset', 'normal',
      'mysetting on', null
    ]
    [ 'properties' ]
  ]
  [
    'InputEvent'
    'beforeinput'
    { bubbles: true, cancelable: false, detail: 0, data: '', isComposing: false }
    [ 'beforeinput', true, false, 0, '', false, null, null ]
    [ 'properties' ]
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
    [ 'keyup', false, false, 0, 16383, 'k', '75', 0, true, false, null, null ]
    [ 'modifiers', 'properties' ]
  ]
  [
    'MouseEvent'
    'click'
    {
      detail: 0, ctrlKey: true, shiftKey: true, altKey: true, metaKey: true,
      modifierAltGraph: true, modifierCapsLock: true, modifierFn: true, modifierFnLock: true,
      modifierHyper: true, modifierNumLock: true, modifierScrollLock: true, modifierSuper: true,
      modifierSymbol: true, modifierSymbolLock: true,
      screenX: 100, screenY: 200, clientX: 300, clientY: 400, button: 1, buttons: 3,
    }
    [ 'click', false, false, 0, 16383, 100, 200, 300, 400, 1, 3, null, null, null ]
    [ 'modifiers', 'properties' ]
  ]
  [
    'PointerEvent'
    'pointerup'
    {
      detail: 0, ctrlKey: false, shiftKey: false, altKey: true, metaKey: false,
      modifierAltGraph: false, modifierCapsLock: false, modifierFn: false, modifierFnLock: false,
      modifierHyper: false, modifierNumLock: false, modifierScrollLock: false, modifierSuper: false,
      modifierSymbol: false, modifierSymbolLock: false,
      screenX: 100, screenY: 200, clientX: 30, clientY: 40, button: 0, buttons: 0,
      pointerId: 4, width: 2, height: 2, pressure: 1, tangentialPressure: 1,
      tiltX: 20, tiltY: -15, twist: 4, pointerType: 'pen', isPrimary: true,
    }
    [
      'pointerup', false, false, 0, 4, 100, 200, 30, 40, 0, 0,
      4, 2, 2, 1, 1, 20, -15,4, 'pen', true, null, null, null
    ]
    [ 'modifiers', 'properties' ]
  ]
  [
    'UIEvent'
    'swipe'
    { bubbles: true, cancelable: true, detail: 10 }
    [ 'swipe', true, true, 10, null, null ]
    [ 'properties' ]
  ]
  [
    'WheelEvent'
    'wheel'
    {
      detail: 0, ctrlKey: true, shiftKey: true, altKey: true, metaKey: true,
      modifierAltGraph: true, modifierCapsLock: true, modifierFn: true, modifierFnLock:true,
      modifierHyper: true, modifierNumLock: true, modifierScrollLock: true, modifierSuper: true,
      modifierSymbol: true, modifierSymbolLock: true,
      screenX: 100, screenY: 200, clientX: 300, clientY: 400, button: 1, buttons: 3,
      deltaX: 123, deltaY: 0, deltaZ: 0, deltaMode: 1,
    }
    [ 'wheel', false, false, 0, (16383), 100, 200, 300, 400, 1, 3, 123, 0, 0, 1, null, null, null ],
    [ 'modifiers', 'properties' ]
  ]
]

for params in testParams
  do (params)->
    [eventName, eventType, init, expectedSplit, checks] = params
    describe "connector.#{eventName}", ->
      describeEventUnitTests eventName, eventType, -> [ init, expectedSplit, checks ]


# CHECK FUNCTIONS


before ->
  check.properties = (expected, actual, messagePrefix = "")->
    for key in Object.keys expected
      do (key)->
        expectedValue = expected[key]
        actualValue = actual[key]
        nullMessage = "#{messagePrefix} testing against null input in property: #{key}"
        valueMessage = "#{messagePrefix}.#{key} should be #{expectedValue}; got #{actualValue}"
        (expectedValue is null).should.be.false nullMessage
        if typeof actualValue is 'object'
          actualValue.should.be.eql expectedValue
        else
          (actualValue is expectedValue).should.be.true valueMessage

  check.modifiers = (expected, actual)->
    modifiers = Object.keys(expected).filter (key)->key.startsWith 'modifier'
    for key in modifiers
      do (key)->
        expectedValue = expected[key]
        actualValue = actual.getModifierState key.substring 'modifier'.length
        nullMessage = "testing against null input in modifier: #{key}"
        valueMessage = "#{expected.constructor}.getModifierState('#{key}')"+
          " should be #{expectedValue}; got #{actualValue}"
        (expectedValue is null).should.be.false nullMessage
        (expectedValue is actualValue).should.be.true valueMessage
        delete expected[key]

  check.clipboardData = (expected, actual)->
    actual.clipboardData.getData(expected.dataFormat).should.equal expected.data

  check.touchLists = (expected, actual)->
    for key in [ 'touches', 'targetTouches', 'changedTouches' ]
      do (key)->
        expectedList = expected[key]
        actualList = actual[key]
        lengthMessage = "length of #{key} should be #{expectedList.length}; got #{actualList.length}"
        (expectedList.length is actualList.length).should.be.true lengthMessage
        check.touchList expectedList, actualList, key
        delete expected[key]

  check.touchList = (expected, actual, messagePrefix = "")->
    expected.forEach (expectedValue, index)->
      actualValue = actual.item index

      expectedInit = {}
      expectedInit[key] = expectedValue[key] for key in [
        'identifier', 'target', 'clientX', 'clientY', 'screenX', 'screenY',
        'pageX', 'pageY', 'radiusX', 'radiusY', 'rotationAngle', 'force',
      ]
      check.properties expectedInit, actualValue, "#{messagePrefix}[#{index}]"

