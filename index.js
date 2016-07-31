// license: MIT
'use strict';

var check = require('offensive');

var constructors = {
  'Event': EventConnector,
  'AnimationEvent': extend(EventConnector)
    .withProperties('animationName', 'elapsedTime', 'pseudoElement'),
  'BeforeUnloadEvent': EventConnector,
  'ClipboardEvent': ClipboardEventConnector,
  'CompositionEvent': extend(EventConnector).withProperties('data', 'locale', 'view'),
  'CustomEvent': extend(EventConnector).withProperties('detail'),
  'FocusEvent': extend(UIEventConnector).withProperties('relatedTarget'),
  'FontFaceEvent': extend(EventConnector).withProperties('family', 'src', 'usedSrc', 'style',
      'weight', 'stretch', 'unicodeRange', 'variant', 'featureSetting'),
  'HashChangeEvent': extend(EventConnector).withProperties('oldURL', 'newURL'),
  'InputEvent': extend(UIEventConnector).withProperties('data', 'isComposing'),
  'KeyboardEvent': extend(ModifierEventConnector)
    .withProperties('key', 'code', 'location', 'repeat', 'isComposing'),
  'MouseEvent': MouseEventConnector,
  'PageTransitionEvent': extend(EventConnector).withProperties('persisted'),
  'PointerEvent': extend(MouseEventConnector).withProperties('pointerId', 'width', 'height',
      'pressure', 'tangentialPressure', 'tiltX', 'tiltY', 'twist', 'pointerType', 'isPrimary'),
  'PopStateEvent': extend(EventConnector).withProperties('state'),
  'TouchEvent': TouchEventConnector,
  'Touch': extend(InitBasedConnector).withProperties('identifier', 'target', 'clientX', 'clientY',
      'screenX', 'screenY', 'pageX', 'pageY', 'radiusX', 'radiusY', 'rotationAngle', 'force'),
  'TransitionEvent': extend(EventConnector)
    .withProperties('propertyName', 'elapsedTime', 'pseudoElement'),
  'UIEvent': UIEventConnector,
  'WheelEvent': extend(MouseEventConnector)
    .withProperties('deltaX', 'deltaY', 'deltaZ', 'deltaMode'),
};

module.exports = function getAllConnectors(namespace, keys) {
  check(namespace, 'namespace').is.anObject();

  var connectors = {};
  Object.keys(constructors)
    .filter(function(name) { return typeof namespace[name] === 'function'; })
    .forEach(function(name) { connectors[name] = constructors[name](namespace[name], keys); });
  return connectors;
}

module.exports.InitBased = InitBasedConnector;

Object.keys(constructors).forEach(function(name) {
  module.exports[name] = constructors[name];
});

function TouchEventConnector(TouchEvent, additionalKeys) {
  var touchListKeys = [ 'touches', 'targetTouches', 'changedTouches' ];
  var keys = touchListKeys
    .concat([ 'altKey', 'metaKey', 'ctrlKey', 'shiftKey' ])
    .concat(additionalKeys || []);

  function touchListToArray(list) {
    var array = [];
    for (var i = 0; i < list.length; ++i) {
      array.push(list.item(i));
    }
    return array;
  }

  var connector = new UIEventConnector(TouchEvent, keys);

  connector.split = pipe(connector.split, function(retVal) {
    touchListKeys.forEach(function(key) {
      var index = connector.indexOf(key);
      retVal[index] = touchListToArray(retVal[index]);
    });
  });
  return connector;
}

function MouseEventConnector(MouseEvent, additionalKeys) {
  var keys = ['screenX', 'screenY', 'clientX', 'clientY', 'button', 'buttons']
    .concat(additionalKeys || [])
    .concat([ 'relatedTarget' ]);
  return new ModifierEventConnector(MouseEvent, keys);
}

// All modifiers are being reduced to a mask during stringification.
function ModifierEventConnector(Event, additionalKeys) {
  var propertyModifiers = [
    'ctrlKey', 'shiftKey', 'altKey', 'metaKey',
  ];
  var stateModifiers = [
    'AltGraph', 'CapsLock', 'Fn', 'FnLock', 'Hyper',
    'NumLock', 'ScrollLock', 'Super', 'Symbol', 'SymbolLock',
  ];
  var keys = propertyModifiers
    .concat(stateModifiers.map(function(key) { return 'modifier'+ key; }))
    .concat(additionalKeys || []);

  function reduce(modifierValues) {
    var mask = 0;
    modifierValues.forEach(function(value, i) {
      if (value) {
        mask |= (0x01 << i);
      }
    });
    return mask;
  }
  function expand(mask) {
    return propertyModifiers.concat(stateModifiers)
      .map(function(key, i) { return !!(mask & (0x01 << i)); })
      ;
  }

  var connector = new UIEventConnector(Event, keys);
  var index = connector.indexOf(propertyModifiers[0]);

  connector.split = pipe(connector.split, function(retVal, evt) {
    var modifiers = retVal.splice(index, propertyModifiers.length + stateModifiers.length, 0);
    retVal[index] = reduce(modifiers);
    return retVal;
  });
  connector.create = pipe(function(args) {
    [].splice.apply(args, [ index, 1 ].concat(expand(args[index])));
    return args;
  }, connector.create);

  return connector;
}

function UIEventConnector(UIEvent, additionalKeys) {
  var keys = [ 'detail' ].concat(additionalKeys || []).concat([ 'view' ]);
  return new EventConnector(UIEvent, keys);
}

function ClipboardEventConnector(ClipboardEvent, additionalKeys) {
  var keys = ['dataType', 'data'].concat(additionalKeys || []);
  var connector = new EventConnector(ClipboardEvent, keys);

  var format = 'text/plain';
  connector.split = pipe(connector.split, function(retVal, evt) {
    retVal[connector.indexOf('dataType')] = format;
    retVal[connector.indexOf('data')] = evt.clipboardData.getData(format);
  });
  return connector;
}

function EventConnector(Event, additionalKeys) {
  var keys = [ 'type', 'bubbles', 'cancelable' ].concat(additionalKeys || []).concat([ 'target' ]);

  var connector = new InitBasedConnector(function(init) {
    return new Event(init.type, init);
  }, keys);

  connector.by = Event;
  return connector;
}

function InitBasedConnector(Constructor, keys) {
  check(Constructor, 'Constructor').is.aFunction();
  check(keys, 'keys').is.anArray();

  return {
    by: Constructor,
    split: splitProperties(keys),
    create: createWithInit(Constructor, keys),
    indexOf: [].indexOf.bind(keys),
  };
}

function splitProperties(keys) {
  return function split(e) {
    return keys.map(function(key) { return e[key]; })
  };
}

function createWithInit(Constructor, keys) {
  return function create(args) {
    var init = {};
    args.forEach(function(val, i) { init[keys[i]] = val; });
    var instance = new Constructor(init);

    // Target element is deserialized to parsedTarget non-standard property,
    // because event.target property is read-only and set by the browser
    // during call to Element.dispatchEvent().
    // TODO move this to EventConnector
    if (typeof init.target !== 'undefined') {
      instance.parsedTarget = init.target;
    }
    return instance;
  };
}

function extend(Connector) {
  return {
    withProperties: function () {
      var additionalKeys = [].slice.call(arguments);

      return function(Constructor, evenMoreKeys) {
        return new Connector(Constructor, additionalKeys.concat(evenMoreKeys || []));
      };
    },
  };
}

function pipe(previous, next) {
  return function() {
    var args = [].slice.call(arguments);
    var retVal = previous.apply(null, args);
    return next.apply(null, [ retVal ].concat(args)) || retVal;
  };
}

