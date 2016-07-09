'use strict'

extend = (EventClass, propertyNames...) ->
  class ExtendedEvent extends EventClass
    constructor: (eventType, properties)->
      @[key] = properties[key] for key in propertyNames
      super eventType, properties

module.exports = (window) ->
  AnimationEvent = extend window.Event, 'animationName', 'elapsedTime', 'pseudoElement'
  BeforeUnloadEvent = extend window.Event, 'returnValue'

  class TransferData
    constructor: (data)-> @data = data
    getData: -> @data
  class ClipboardEvent extends window.Event
    constructor: (eventType, properties)->
      @clipboardData = new TransferData properties.data
      super eventType, properties

  CompositionEvent = extend window.UIEvent, 'data', 'locale'
  CloseEvent = extend window.Event, 'code', 'wasClean', 'reason'
  InputEvent = extend window.UIEvent, 'data', 'isComposing'
  FontFaceEvent = extend window.Event, 'family', 'src', 'usedSrc',
        'style', 'weight', 'stretch', 'unicodeRange', 'variant', 'featureSetting'

  window.AnimationEvent = AnimationEvent if !window.AnimationEvent?
  window.BeforeUnloadEvent = BeforeUnloadEvent if !window.BeforeUnloadEvent?
  window.ClipboardEvent = ClipboardEvent if !window.ClipboardEvent?
  window.CompositionEvent = CompositionEvent if !window.CompositionEvent?
  window.CloseEvent = CloseEvent if !window.CloseEvent?
  window.FontFaceEvent = FontFaceEvent if !window.FontFaceEvent?
  window.InputEvent = InputEvent if !window.InputEvent?

  window

