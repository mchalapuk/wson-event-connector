// license: MIT
'use strict';

module.exports = forAllEventInterfaces;

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

var constructors = {
  'Event': EventConnector,
  'AnimationEvent': construct(EventConnector)
    .withProperties('animationName', 'elapsedTime', 'pseudoElement'),
  'BeforeUnloadEvent': EventConnector,
  'ClipboardEvent': ClipboardEventConnector,
  'CloseEvent': construct(EventConnector).withProperties('code', 'reason', 'wasClean'),
  'CustomEvent': construct(EventConnector).withProperties('detail'),
  'UIEvent': UIEventConnector,
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


function PropertyBasedConnector(Event, keys) {
  return {
    by: Event,
    split: splitProperties(keys),
    create: createWithProperties(Event, keys),
    indexOf: indexOf([ 'type' ].concat(keys)),
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
    return keys.indexOf(key);
  };
}

function construct(Connector) {
  return {
    withProperties: function () {
      var additionalKeys = [].slice.call(arguments);

      return function(Event) {
        return new EventConnector(Event, additionalKeys);
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

