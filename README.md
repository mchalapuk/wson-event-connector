[npm-url]: https://npmjs.org/package/wson-event-connector
[npm-image]: https://img.shields.io/npm/v/wson-event-connector.svg?maxAge=2592000

[travis-url]: http://travis-ci.org/webfront-toolkit/wson-event-connector
[travis-image]: https://img.shields.io/travis/webfront-toolkit/wson-event-connector.svg?maxAge=2592000

[david-url]: https://david-dm.org/webfront-toolkit/wson-event-connector
[david-image]: https://david-dm.org/webfront-toolkit/wson-event-connector.svg

[david-url-dev]: https://david-dm.org/webfront-toolkit/wson-event-connector#info=devDependencies
[david-image-dev]: https://david-dm.org/webfront-toolkit/wson-event-connector/dev-status.svg

[license-url]: LICENSE
[license-image]: https://img.shields.io/github/license/webfront-toolkit/wson-event-connector.svg?maxAge=2592000

# wson-event-connector

[![NPM version][npm-image]][npm-url]
[![Build Status][travis-image]][travis-url]
[![Dependency Status][david-image]][david-url]
[![devDependency Status][david-image-dev]][david-url-dev]
[![License][license-image]][license-url]

[WSON][wson] is a human-readable data-interchange format with support for cyclic
structures. This module is an extension to wson that enables serializing
[DOM events][events] to strings and parsing those strings back to DOM events.

[wson]: https://github.com/tapirdata/wson
[events]: https://developer.mozilla.org/en-US/docs/Web/API/Event

**Possible Use Cases**

 1. Store references to DOM events between page reloads,
 2. Record DOM events to later simulate a user during automated test.

## Installation

```shell
npm install --save wson wson-event-connector
```

## Usage

It can be used in a web browser via [browserify][browserify]...

[browserify]: https://github.com/substack/node-browserify

```javascript
var WSON = require("wson");
var EventConnector = require("wson-event-connector");

var wson = new WSON({
  connectors: EventConnector.forAllEventInterfaces(window)
  });

console.log(wson.stringify(new window.MouseEvent('click')));
// TODO
```

...or in [node][node] with any standard-compliant DOM implementation
(e.g. [jsdom][jsdom]).

[node]: https://nodejs.org/en/
[jsdom]: https://github.com/tmpvar/jsdom

```javascript
var WSON = require("wson");
var EventConnector = require("wson-event-connector");
var jsdom = require("jsdom");

var window = jsdom.jsdom("<body></body>").defaultView;

var wson = new WSON({
  connectors: EventConnector.forAllEventInterfaces(window)
  });

console.log(wson.stringify(new window.MouseEvent('click')));
// TODO
```

## API
Please refer to [wson's documentation][wson] for further details.

## License

Copyright &copy; 2016 Maciej Chałapuk.
Released under [MIT license](LICENSE).
