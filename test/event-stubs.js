
'use strict'

function extend (EventClass, defaults) {
  class ExtendedEvent extends EventClass {
    constructor(eventType, init) {
      super(eventType, init);

      const self = this;
      Object.keys(defaults)
        .forEach(key => self[key] = typeof init[key] !== 'undefined' ? init[key] : defaults[key])
      ;
    }
  }
  return ExtendedEvent;
}

module.exports = (window) => {
  const AnimationEvent = extend(window.Event, {
    animationName: null, elapsedTime: 0, pseudoElement: null,
  });
  const BeforeUnloadEvent = extend(window.Event, { returnValue: null });

  class TransferData {
    constructor(data) {
      this.data = data;
    }
    getData() {
      return this.data;
    }
  }
  class ClipboardEvent extends window.Event {
    constructor(eventType, init) {
      super(eventType, init);
      this.clipboardData = new TransferData(init.data);
    }
  }

  const FontFaceEvent = extend(window.Event, {
    family: null, src: null, usedSrc: null, style: null,
    weight: null, stretch: null, unicodeRange: null, variant: null, featureSetting: null,
  });

  const CompositionEvent = extend(window.UIEvent, { data: null, locale: null });
  const InputEvent = extend(window.UIEvent, { data: null, isComposing: false });

  class ModifierEvent extends (
    extend(window.UIEvent, {
      ctrlKey: false, shiftKey: false, altKey: false, metaKey: false,
      modifierAltGraph: false, modifierCapsLock: false, modifierFn: false, modifierFnLock: false,
      modifierHyper: false, modifierNumLock: false, modifierScrollLock: false, modifierSuper: false,
      modifierSymbol: false, modifierSymbolLock: false,
    })
  ) {
    getModifierState(key) {
      return this[`modifier${key}`];
    }
  }

  const KeyboardEvent = extend(ModifierEvent, {
    key: null, code: null, location: 0, repeat: false, isComposing: false
  });
  const MouseEvent = extend(ModifierEvent, {
    screenX: 0, screenY: 0, clientX: 0, clientY: 0, button: 0, buttons: 0, relatedTarget: null
  });
  const PointerEvent = extend(MouseEvent, {
    pointerId: 0, width: 1, height: 1, pressure: 0, tangentialPressure: 0,
    tiltX: 0, tiltY: 0, twist: 0, pointerType: "", isPrimary: false,
  });
  const WheelEvent = extend(MouseEvent, {
    deltaX: 0.0, deltaY: 0.0, deltaZ: 0.0, deltaMode: 0
  });

  class Touch {
    constructor(init) {
      const defaults = {
        clientX: 0, clientY: 0, screenX: 0, screenY: 0, pageX: 0, pageY: 0,
        radiusX: 0, radiusY: 0, rotationAngle: 0, force: 0,
      }

      if (!init.identifier) {
        throw new Error('identifier field is required');
      }
      this.identifier = init.identifier
      if (!init.target) {
        throw new Error('target field is required');
      }
      this.target = init.target

      Object.keys(defaults)
        .forEach(key => this[key] = typeof init[key] !== 'undefined' ? init[key] : defaults[key])
      ;
    }
  }
  class TouchList {
    constructor(touches) {
      this.touches = touches
      this.length = this.touches.length
    }
    item(index) {
      return this.touches[index];
    }
  }

  class TouchEvent extends (
    extend(window.UIEvent, {
      altKey: false, metaKey: false, ctrlKey: false, shiftKey: false,
    })
  ) {
    constructor(eventType, init) {
      super(eventType, init);

      [ 'touches', 'targetTouches', 'changedTouches' ].forEach(key => {
        this[key] = new TouchList(init[key]);
      });
    }
  }

  const PageTransitionEvent = extend(window.Event, { persisted: false });
  const TransitionEvent = extend(window.Event, {
    propertyName: undefined, elapsedTime: 0, pseudoElement: '',
  });

  window.AnimationEvent = AnimationEvent;
  window.BeforeUnloadEvent = BeforeUnloadEvent;
  window.ClipboardEvent = ClipboardEvent;
  window.CompositionEvent = CompositionEvent;
  window.FontFaceEvent = FontFaceEvent;
  window.KeyboardEvent = KeyboardEvent;
  window.MouseEvent = MouseEvent;
  window.PointerEvent = PointerEvent;
  window.Touch = Touch;
  window.TouchEvent = TouchEvent;
  window.WheelEvent = WheelEvent;
  window.InputEvent = InputEvent;
  window.PageTransitionEvent = PageTransitionEvent;
  window.TransitionEvent = TransitionEvent;

  return window;
}

