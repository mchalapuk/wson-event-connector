// license: MIT
'use strict';

module.exports = forAllEventInterfaces;

var constructors = {
  'Event': EventConnector,
};

function forAllEventInterfaces(window, document) {
  var connectors = {};
  Object.keys(constructors).forEach(function(name) {
    if (typeof window[name] === 'undefined') {
      return;
    }
    connectors[name] = constructors[name](window[name]);
  });
  return connectors;
}

function EventConnector(Event, additionalKeys) {
  var keys = [ 'bubbles', 'cancelable', 'target' ].concat(additionalKeys || []);

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

