'use strict'

module.exports = (window) ->
  class AnimationEvent extends window.Event
    constructor: (eventType, properties)->
      @animationName = properties.animationName
      @elapsedTime = properties.elapsedTime
      @pseudoElement = properties.pseudoElement
      super eventType, properties
  window.AnimationEvent = AnimationEvent
  window

