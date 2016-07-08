// license: MIT
'use strict';

module.exports = forAllEventInterfaces;

var constructors = {
  'Event': EventConnector,
  'AnimationEvent': withProperties('animationName', 'elapsedTime', 'pseudoElement'),
  'BeforeUnloadEvent': EventConnector,
  'ClipboardEvent': ClipboardEventConnector,
  'CloseEvent': withProperties('code', 'reason', 'wasClean'),
};

function forAllEventInterfaces(namespace) {
  if (!namespace) {
    throw new Error('Passed namespace is not an object.');
  }

  var connectors = {};
  Object.keys(constructors).forEach(function(name) {
    if (typeof namespace[name] === 'undefined') {
      return;
    }
    connectors[name] = constructors[name](namespace[name]);
  });
  return connectors;
}

function withProperties() {
  var additionalKeys = [].slice.call(arguments)
  return function(Event) {
    return new EventConnector(Event, additionalKeys);
  };
}

function EventConnector(Event, additionalKeys) {
  var keys = [ 'bubbles', 'cancelable' ].concat(additionalKeys || []).concat( [ 'target' ] );

  return {
    by: Event,
    split: splitProperties(keys),
    create: createWithProperties(Event, keys),
  }
}

function ClipboardEventConnector(Event) {
  var format = 'text/plain';

  function split(e) {
    return [ e.type, e.bubbles, e.cancelable, format, e.clipboardData.getData(format), e.target ];
  }

  return {
    by: Event,
    split: split,
    create: createWithProperties(Event, ['bubbles', 'cancelable', 'dataType', 'data', 'target']),
  };
}

function splitProperties(keys) {
  return function split(e) {
    return [ e.type ].concat(keys.map(function(key) { return e[key]; }))
  };
}

function createWithProperties(Event, keys) {
  return function create(args) {
    var properties = {};
    args.slice(1).forEach(function(val, i) { properties[keys[i]] = val; });
    var e = new Event(args[0], properties);

    // Target element is deserialized to parsedTarget non-standard property,
    // because event.target property is read-only and set by the browser
    // during call to Element.dispatchEvent().
    e.parsedTarget = properties.target;
    return e;
  };
}

