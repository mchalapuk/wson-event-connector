'use strict'

extend = (EventClass, defaults) ->
  class ExtendedEvent extends EventClass
    constructor: (eventType, init)->
      for key in Object.keys defaults
        do (key)=> @[key] = if typeof init[key] is 'undefined' then defaults[key] else init[key]
      super eventType, init

module.exports = (window) ->
  AnimationEvent = extend window.Event, animationName: null, elapsedTime: 0, pseudoElement: null
  BeforeUnloadEvent = extend window.Event, returnValue: null

  class TransferData
    constructor: (data)-> @data = data
    getData: -> @data
  class ClipboardEvent extends window.Event
    constructor: (eventType, init)->
      @clipboardData = new TransferData init.data
      super eventType, init

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
    constructor: (eventType, init)-> super eventType, init
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

  class Touch
    defaults = {
      clientX: 0, clientY: 0, screenX: 0, screenY: 0, pageX: 0, pageY: 0,
      radiusX: 0, radiusY: 0, rotationAngle: 0, force: 0,
    }
    constructor: (init)->
      @identifier = init.identifier or throw new Error('identifier field is required')
      @target = init.target or throw new Error('target is required')
      Object.keys(defaults).forEach (key)=>
        @[key] = if typeof init[key] is 'undefined' then defaults[key] else init[key]
  class TouchList
    constructor:(touches)->
      @touches = touches
      @length = @touches.length
    item: (index)-> @touches[index]

  class TouchEvent extends (
    extend window.UIEvent, {
      altKey: false, metaKey: false, ctrlKey: false, shiftKey: false,
    }
  )
    constructor: (eventType, init)->
      super eventType, init
      @[key] = new TouchList(init[key]) for key in [ 'touches', 'targetTouches', 'changedTouches' ]

  PageTransitionEvent = extend window.Event, persisted: false
  TransitionEvent = extend window.Event, propertyName: undefined, elapsedTime: 0, pseudoElement: ''

  window.AnimationEvent = AnimationEvent if !window.AnimationEvent?
  window.BeforeUnloadEvent = BeforeUnloadEvent if !window.BeforeUnloadEvent?
  window.ClipboardEvent = ClipboardEvent if !window.ClipboardEvent?
  window.CompositionEvent = CompositionEvent if !window.CompositionEvent?
  window.FontFaceEvent = FontFaceEvent if !window.FontFaceEvent?
  window.KeyboardEvent = KeyboardEvent #if !window.KeyboardEvent?
  window.MouseEvent = MouseEvent #if !window.MouseEvent?
  window.PointerEvent = PointerEvent #if !window.PointerEvent?
  window.Touch = Touch #if !window.Touch?
  window.TouchEvent = TouchEvent #if !window.TouchEvent?
  window.WheelEvent = WheelEvent #if !window.WheelEvent?
  window.InputEvent = InputEvent if !window.InputEvent?
  window.PageTransitionEvent = PageTransitionEvent if !window.PageTransitionEvent?
  window.TransitionEvent = TransitionEvent if !window.TransitionEvent?

  window

