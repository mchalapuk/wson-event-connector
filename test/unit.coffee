mocha = require 'mocha'
should = require 'should'

jsdom = require 'jsdom'
_ = require 'underscore'
declareMissingEvents = require './event-stubs.coffee'

delete require.cache[ require.resolve '../' ]
connectors = require '..'

testParams = [
  [
    'Event'
    'generic'
    { bubbles: false, cancelable: false }
    [ 'generic', false, false, null ]
  ]
  [
    'AnimationEvent'
    'test'
    {
      bubbles: false, cancelable: true
      animationName: 'testAnim', elapsedTime: 100, pseudoElement: 'pseudo'
    }
    [ 'test', false, true, 'testAnim', 100, 'pseudo', null ]
  ]
  [
    'BeforeUnloadEvent'
    'beforeunload'
    { bubbles: false, cancelable: true  }
    [ 'beforeunload', false, true, null ]
  ]
  [
    'ClipboardEvent'
    'copy'
    { bubbles: true, cancelable: true, dataFormat: 'text/plain', data: 'https://github.com/' }
    [ 'copy', true, true, 'text/plain', 'https://github.com/', null ]
  ]
  [
    'CloseEvent'
    'close'
    { bubbles: false, cancelable: false, code: 1000, reason: '', wasClean: true }
    [ 'close', false, false, 1000, '', true, null ]
  ]
  [
    'CompositionEvent'
    'start'
    { bubbles: true, cancelable: true, data: 'deleted text', locale: 'C' }
    [ 'start', true, true, 'deleted text', 'C', null, null ]
  ]
  [
    'CustomEvent'
    'chat'
    { bubbles: false, cancelable: false, detail: { contact: '@Matilda' } }
    [ 'chat', false, false, { contact: '@Matilda' }, null ]
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
  ]
  [
    'InputEvent'
    'beforeinput'
    { bubbles: true, cancelable: false, detail: 0, data: '', isComposing: false }
    [ 'beforeinput', true, false, 0, '', false, null, null ]
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
    [ 'click', false, false, 0, (16383), 100, 200, 300, 400, 1, 3, null, null, null ]
  ]
  [
    'UIEvent'
    'swipe'
    { bubbles: true, cancelable: true, detail: 10 }
    [ 'swipe', true, true, 10, null, null ]
  ]
]

window = null
before -> window = declareMissingEvents jsdom.jsdom().defaultView
after -> window.close()

for params in testParams
  do (params)->
    [eventName, eventType, properties, expectedSplit] = params

    describe "connector.#{eventName}", ->
      testedConnector = null
      event = null

      beforeEach ->
        testedConnector = connectors[eventName] window[eventName]
        event = new window[eventName] eventType, properties

      describe ".by", ->
        it "should be #{eventName}\'s constructor", ->
          testedConnector.by.should.be.exactly window[eventName]

      describe ".split", ->
        it "should return #{expectedSplit}", ->
          testedConnector.split(event).should.be.eql expectedSplit

      describe ".create", ->
        it "should return instance of #{eventName}", ->
          created = testedConnector.create expectedSplit
          created.type.should.equal eventType
          if created instanceof window.MouseEvent
            checkModifiers properties, created
          if created instanceof window.ClipboardEvent
            created.clipboardData.getData(properties.dataFormat).should.equal properties.data
          else
            checkProperties properties, created
          created.constructor.should.equal window[eventName]

checkProperties = (properties, created)->
  for key in Object.keys properties
    (key)->
      expected = properties[key]
      actual = created[key]
      (expected is null).should.be.false "testing against null input in properties.#{key}"
      (actual is expected).should.be.false "event.#{key} should be #{expected}; got #{actual}"

checkModifiers = (properties, created)->
  modifiers = Object.keys(properties).filter (key)->key.startsWith 'modifier'
  for key in modifiers
    do (key)->
      expected = properties[key]
      actual = created.getModifierState key.substring 'modifier'.length
      (expected is null).should.be.false "testing against null input in properties.#{key}"
      (expected is actual).should.be.true "wrong value of modifier #{key}: #{actual}"
      delete properties[key]

