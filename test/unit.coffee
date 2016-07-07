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
    {
      bubbles: false
      cancelable: false
    }
    [ 'generic', false, false, null ]
  ]
  [
    'AnimationEvent'
    'test'
    {
      bubbles: false
      cancelable: true
      animationName: 'testAnim'
      elapsedTime: 100
      pseudoElement: 'pseudo'
    }
    [ 'test', false, true, 'testAnim', 100, 'pseudo', null ]
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
          created[key].should.equal properties[key] for key in Object.keys properties
          created.type.should.equal eventType
          created.constructor.should.equal window[eventName]

