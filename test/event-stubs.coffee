'use strict'

extend = (EventClass, defaults) ->
  class ExtendedEvent extends EventClass
    constructor: (eventType, properties)->
      for key in Object.keys defaults
        do (key)=>
          @[key] = if typeof properties[key] is 'undefined' then defaults[key] else properties[key]
      super eventType, properties

module.exports = (window) ->
  AnimationEvent = extend window.Event, animationName: null, elapsedTime: 0, pseudoElement: null
  BeforeUnloadEvent = extend window.Event, returnValue: null

  class TransferData
    constructor: (data)-> @data = data
    getData: -> @data
  class ClipboardEvent extends window.Event
    constructor: (eventType, properties)->
      @clipboardData = new TransferData properties.data
      super eventType, properties

  CloseEvent = extend window.Event, code: 0, wasClean: false, reason: null
  FontFaceEvent = extend window.Event, {
    family: null, src: null, usedSrc: null, style: null,
    weight: null, stretch: null, unicodeRange: null, variant: null, featureSetting: null
  }

  CompositionEvent = extend window.UIEvent, data: null, locale: null
  InputEvent = extend window.UIEvent, data: null, isComposing: false

  class ModifierEvent extends (
    extend window.UIEvent, {
      ctrlKey: false, shiftKey: false, altKey: false, metaKey: false,
      modifierAltGraph: false, modifierCapsLock: false, modifierFn: false, modifierFnLock: false,
      modifierHyper: false, modifierNumLock: false, modifierScrollLock: false, modifierSuper: false,
      modifierSymbol: false, modifierSymbolLock: false
    }
  )
    constructor: (eventType, properties)-> super eventType, properties
    getModifierState: (key)-> @["modifier#{key}"]

  KeyboardEvent = extend ModifierEvent, {
    key: null, code: null, location: 0, repeat: false, isComposing: false
  }
  MouseEvent = extend ModifierEvent, {
    screenX: 0, screenY: 0, clientX: 0, clientY: 0, button: 0, buttons: 0, relatedTarget: null
  }
  PointerEvent = extend MouseEvent, {
    pointerId: 0, width: 1, height: 1, pressure: 0, tangentialPressure: 0,
    tiltX: 0, tiltY: 0, twist: 0, pointerType: "", isPrimary: false,
  }
  WheelEvent = extend MouseEvent, {
    deltaX: 0.0, deltaY: 0.0, deltaZ: 0.0, deltaMode: 0
  }

  window.AnimationEvent = AnimationEvent if !window.AnimationEvent?
  window.BeforeUnloadEvent = BeforeUnloadEvent if !window.BeforeUnloadEvent?
  window.ClipboardEvent = ClipboardEvent if !window.ClipboardEvent?
  window.CompositionEvent = CompositionEvent if !window.CompositionEvent?
  window.CloseEvent = CloseEvent if !window.CloseEvent?
  window.FontFaceEvent = FontFaceEvent if !window.FontFaceEvent?
  window.KeyboardEvent = KeyboardEvent #if !window.KeyboardEvent?
  window.MouseEvent = MouseEvent #if !window.MouseEvent?
  window.PointerEvent = PointerEvent #if !window.PointerEvent?
  window.WheelEvent = WheelEvent #if !window.WheelEvent?
  window.InputEvent = InputEvent if !window.InputEvent?

  window

