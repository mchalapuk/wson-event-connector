'use strict'

module.exports = (window) ->

  class AnimationEvent extends window.Event
    constructor: (eventType, properties)->
      @animationName = properties.animationName
      @elapsedTime = properties.elapsedTime
      @pseudoElement = properties.pseudoElement
      super eventType, properties

  class BeforeUnloadEvent extends window.Event
    constructor: (eventType, properties)->
      @returnValue = null
      super eventType, properties

  class TransferData
    constructor: (data)-> @data = data
    getData: -> @data

  class ClipboardEvent extends window.Event
    constructor: (eventType, properties)->
      @clipboardData = new TransferData properties.data
      super eventType, properties

  class CompositionEvent extends window.UIEvent
    constructor: (eventType, properties)->
      @data = properties.data
      @locale = properties.locale
      super eventType, properties

  class CloseEvent extends window.Event
    constructor: (eventType, properties)->
      @code = properties.code
      @wasClean = properties.wasClean
      @reason = properties.reason
      super eventType, properties

  window.AnimationEvent = AnimationEvent if !window.AnimationEvent?
  window.BeforeUnloadEvent = BeforeUnloadEvent if !window.BeforeUnloadEvent?
  window.ClipboardEvent = ClipboardEvent if !window.ClipboardEvent?
  window.CompositionEvent = CompositionEvent if !window.CompositionEvent?
  window.CloseEvent = CloseEvent if !window.CloseEvent?

  window

