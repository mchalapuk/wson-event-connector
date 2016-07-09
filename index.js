// license: MIT
'use strict';

var constructors = {
  'Event': EventConnector,
  'AnimationEvent': extend(EventConnector)
    .withProperties('animationName', 'elapsedTime', 'pseudoElement'),
  'BeforeUnloadEvent': EventConnector,
  'ClipboardEvent': ClipboardEventConnector,
  'CloseEvent': extend(EventConnector).withProperties('code', 'reason', 'wasClean'),
  'CompositionEvent': extend(EventConnector).withProperties('data', 'locale', 'view'),
  'CustomEvent': extend(EventConnector).withProperties('detail'),
  'FontFaceEvent': extend(EventConnector).withProperties('family', 'src', 'usedSrc', 'style',
      'weight', 'stretch', 'unicodeRange', 'variant', 'featureSetting'),
  'InputEvent': extend(UIEventConnector).withProperties('data', 'isComposing'),
  'UIEvent': UIEventConnector,
};

module.exports = function getAllConnectors(namespace) {
  check(typeof namespace === 'object', 'Passed namespace is not an object.');

  var connectors = {};
  Object.keys(constructors)
    .filter(function(name) { return typeof namespace[name] === 'function'; })
    .forEach(function(name) { connectors[name] = constructors[name](namespace[name]); });
  return connectors;
}

Object.keys(constructors).forEach(function(name) {
  module.exports[name] = constructors[name];
});

module.exports.PropertyBasedConnector = PropertyBasedConnector;

function EventConnector(Event, additionalKeys) {
  var keys = [ 'bubbles', 'cancelable' ].concat(additionalKeys || []).concat([ 'target' ]);
  return new PropertyBasedConnector(Event, keys);
}

function UIEventConnector(Event, additionalKeys) {
  return new EventConnector(Event, [ 'detail' ].concat(additionalKeys || []).concat([ 'view' ]));
}

function ClipboardEventConnector(Event) {
  var connector = new EventConnector(Event, ['dataType', 'data']);

  var format = 'text/plain';
  connector.split = pipe(connector.split, function(args, e) {
    args[connector.indexOf('dataType')] = format;
    args[connector.indexOf('data')] = e.clipboardData.getData(format);
    return args;
  });
  return connector;
}

function PropertyBasedConnector(Event, keys) {
  check(typeof Event === 'function', 'Event must be a function.')

  return {
    by: Event,
    split: splitProperties(keys),
    create: createWithProperties(Event, keys),
    indexOf: indexOf(keys),
  }
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

function indexOf(keys) {
  return function(key) {
    return [ 'type' ].concat(keys).indexOf(key);
  };
}

function extend(Connector) {
  return {
    withProperties: function () {
      var additionalKeys = [].slice.call(arguments);

      return function(Event, evenMoreKeys) {
        return new Connector(Event, additionalKeys.concat(evenMoreKeys || []));
      };
    },
  };
}

function pipe(previous, next) {
  return function() {
    var args = [].slice.call(arguments);
    var retVal = previous.apply(null, args);
    return next.apply(null, [ retVal ].concat(args));
  };
}

function check(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

