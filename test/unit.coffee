mocha = require 'mocha'
should = require 'should'

jsdom = require 'jsdom'
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
    { cancelable: true, animationName: 'testAnim', elapsedTime: 100, pseudoElement: 'pseudo' }
    [ 'test', false, true, 'testAnim', 100, 'pseudo', null ]
  ]
  [
    'BeforeUnloadEvent'
    'beforeunload'
    { cancelable: true  }
    [ 'beforeunload', false, true, null ]
  ]
  [
    'ClipboardEvent'
    'copy'
    { bubbles: true, cancelable: true, data: 'https://github.com/' }
    [ 'copy', true, true, 'text/plain', 'https://github.com/', null ]
    { data: (e)->e.clipboardData.getData('text/plain') }
  ]
  [
    'CloseEvent'
    'close'
    { bubbles: false, cancelable: false, code: 1000, reason: '', wasClean: true }
    [ 'close', false, false, 1000, '', true, null ]
  ]
  [
    'CustomEvent'
    'chat'
    { bubbles: false, cancelable: false, detail: { contact: '@Matilda' } }
    [ 'chat', false, false, { contact: '@Matilda' }, null ]
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
    [eventName, eventType, properties, expectedSplit, getters] = params
    getters = {} if !getters?
    (getters[key] = ((event)->event[key]) if !getters[key]) for key in Object.keys properties

    describe "connector.#{eventName}", ->
      testedConnector = null
      event = null

      beforeEach ->
        testedConnector = connectors(window)[eventName]
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
          getters[key](created).should.be.eql properties[key] for key in Object.keys properties
          created.type.should.equal eventType
          created.constructor.should.equal window[eventName]

