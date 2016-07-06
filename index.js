// license: MIT
'use strict';

module.exports = forAllEventInterfaces;

var constructors = {
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

