// license: MIT
'use strict';

module.exports = forAllEventInterfaces;

var constructors = {
  'Event': withProperties(),
  'AnimationEvent': withProperties('animationName', 'elapsedTime', 'pseudoElement'),
  'BeforeUnloadEvent': withProperties(),
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
    return new RegularEventConnector(Event, additionalKeys);
  };
}

function RegularEventConnector(Event, additionalKeys) {
  var keys = [ 'bubbles', 'cancelable' ].concat(additionalKeys || []).concat( [ 'target' ] );

  function split(event) {
    return [ event.type ].concat(keys.map(function(key) { return event[key]; }))
  }
  function create(args) {
    var properties = {};
    args.slice(1).forEach(function(val, i) { properties[keys[i]] = val; });
    var e = new Event(args[0], properties);

    // Target element is deserialized to parsedTarget non-standard property,
    // because event.target property is read-only and set by the browser
    // during call to Element.dispatchEvent().
    e.parsedTarget = properties.target;
    return e;
  }

  return {
    by: Event,
    split: split,
    create: create,
  }
}

function SpecializedEventConnector(Event) {
  function returnEmptyArray(event) {
    return [ event.type ]
  }
  function create(args) {
    return new Event(args[0])
  }

  return {
    by: Event,
    split: returnEmptyArray,
    create: create,
  }
}

