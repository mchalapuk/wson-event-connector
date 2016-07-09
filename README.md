[npm-url]: https://npmjs.org/package/wson-event-connector
[npm-image]: https://img.shields.io/npm/v/wson-event-connector.svg?maxAge=1

[travis-url]: http://travis-ci.org/webfront-toolkit/wson-event-connector
[travis-image]: https://img.shields.io/travis/webfront-toolkit/wson-event-connector.svg?maxAge=1

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
var eventConnectors = require("wson-event-connector");

var wson = new WSON({
  connectors: eventConnectors(window)
  });

function logEvent(e) {
  console.log(wson.stringify(e));
}

var events = [ 'load', 'error', 'focus', 'blur', 'resize', 'scroll', 'unload' ];
events.forEach(function(name) {
  window.addEventListener(name, logEvent);
});
```

...or in [node][node] with any standard-compliant DOM implementation
(e.g. [jsdom][jsdom]).

[node]: https://nodejs.org/en/
[jsdom]: https://github.com/tmpvar/jsdom

```javascript
var WSON = require("wson");
var eventConnectors = require("wson-event-connector");
var jsdom = require("jsdom");

var window = jsdom.jsdom("<body></body>").defaultView;

var wson = new WSON({
  connectors: eventConnectors(window)
  });

var body = window.document.body;
body.addEventListener('click', function(event) {
  console.log(wson.stringify(event)));
}
body.dispatchEvent(new window.MouseEvent('click', {
  screenX: 1000,
  screenY: 1000,
  clientX: 300,
  clientY: 400,
  button: 1,
  buttons: 1,
  view: window,
});
// [:MouseEvent|click|#f|#f|#0|#0|#1000|#1000|#300|#400|#1|#1|#n|[:Window]|[:HTMLBodyElement|/html`a1`e/body`a1`e]]
```

## Supported Events

Following events types are currently supported:

 * [`Event`](https://dom.spec.whatwg.org/#interface-event)
  * [`UIEvent`](https://w3c.github.io/uievents/#interface-uievent)
    * [`CompositionEvent`](https://w3c.github.io/uievents/#interface-compositionevent)
    * [`InputEvent`](https://w3c.github.io/uievents/#interface-inputevent)
  * [`AnimationEvent`](https://drafts.csswg.org/css-animations/#interface-animationevent)
  * [`BeforeUnloadEvent`](https://dev.w3.org/html5/spec-LC/history.html#beforeunloadevent)
  * [`ClipboardEvent`](https://w3c.github.io/clipboard-apis/#clipboard-event-interfaces)
  * [`CloseEvent`](https://html.spec.whatwg.org/multipage/comms.html#closeevent)
  * [`CustomEvent`](https://dom.spec.whatwg.org/#interface-customevent)
  * [`FontFaceEvent`](https://wiki.csswg.org/spec/font-load-events)

## Unsupported Events

Serialization of following event classes is not implemented in this module:

 * [`BlobEvent`][blob-event], because [`Blob`][blob]'s content can't be fetched
   from JavaScript.
 * [`SensorReadingEvent`][sensor-reading-event], as it's API involves too many
   interfaces (candidate for separate module).
 * Non-standard vendor-specific events and properties. These should be
   implemented in separate module (e.g.&nbsp;`wson-mozilla-controller`).
   Classes exported from this module can simplify this task (see [API docs][api]).

[blob-event]: https://developer.mozilla.org/en-US/docs/Web/API/BlobEvent
[blob]: https://developer.mozilla.org/en-US/docs/Web/API/Blob
[sensor-reading-event]: https://w3c.github.io/sensors/#the-sensor-reading-event-interface
[api]: #api

## Why are some properties not serialized?

Following properties are by default not serialized:

 * [`Event.defaultPrevented`][default-prevented], because initial value
  of this property is always `true` ([`Event.preventDefault()`][prevent-default]
  called inside an event listener changes it to `false`).
  The whole point of event serialization is to be able to dispatch them
  on another instance of window containing the same HTML document.
  Properties need to be in initial (pre-dispatch) value in order for event
  listeners to work properly.
 * Properties, which contain meta-information about event and current
   state of its propagation ([`Event.currentTarget`][current-target],
  [`Event.eventPhase`][event-phase], [`Event.timeStamp`][time-stamp],
  [`Event.isTrusted`][is-trusted]). Values of these properties are
  changed by the browser during event dispatch and they cannot are
  be set from JavaScript.
 * [`UIEvent.sourceCapabilities`][source-capabilities], because it's just
  ridiculous to pass the same information in each event.

[default-prevented]: https://developer.mozilla.org/en-US/docs/Web/API/Event/defaultPrevented
[prevent-default]: https://developer.mozilla.org/en-US/docs/Web/API/Event/preventDefault
[current-target]: https://developer.mozilla.org/en-US/docs/Web/API/Event/currentTarget
[event-phase]: https://developer.mozilla.org/en-US/docs/Web/API/Event/eventPhase
[time-stamp]: https://developer.mozilla.org/en-US/docs/Web/API/Event/timeStamp
[is-trusted]: https://developer.mozilla.org/en-US/docs/Web/API/Event/isTrusted
[source-capabilities]: https://developer.mozilla.org/en-US/docs/Web/API/UIEvent/sourceCapabilities

## API

This document contains API's exported by this module. Please refer to [wson's documentation][wson] for more.

### All Connectors

```js
exports = function(window) { ... }
```

Creates WSON connectors of all events implemented by this module. Returns a map
from event class name to instance of connector able to serialize events of this
class name found in passed **window** namespace.

```js
var WSON = require('wson');
var connectors = require('wson-event-connector');

var wson = new WSON({ connectors: connectors(window) };
```

### Event Connector

```js
exports.Event = function(EventClass, additionalFields) { ... }
```

Constructs a connector which is able to serialize event instances of passed
**EventClass**. Passed class should be derived from `window.Event`. Fields
are being serialized in following order: `Event.bubbles`, `Event.cancelable`,
**additionalFields**, `Event.target`.

`Event.target` property is not settable from JavaScript. A web browser sets this
property to the instance on which `EventTarget.dispatch(event)` was called.
In events returned from `wson.parse(string)`, value of `Event.target` is `null`.
Target is deserialized into non-standard **`Event.parsedTarget`** property.

```js
var WSON = require('wson');
var eventConnectors = require('wson-event-connector');
var domConnectors = require('wson-dom-connector');

var wson = new WSON({ connectors: {
  'Event': eventConnectors.Event(window.Event),
  'HTMLBodyElement': domConnectors(window).HTMLBodyElement,
  }});

var event = wson.parse('[:Event|load|#f|#t|[:HTMLBodyElement|/html`a1`e/body`a1`e]]');
event.parsedTarget.dispatchEvent(event);
```

### Property Based Connector

```js
exports.PropertyBasedConnector = function(Class, serializedFields) { ... }
```

Constructs a connector which is able to serialize instances of passed **Class**.
There are no requirements regarding serialized class, apart from that is must
be a class. Constructed connector serializes fields of names passed in
**serializedFields** array and in order as the occur in this array.

```js
var WSON = require('wson');
var PropertyBasedConnector = require('wson-event-connector').PropertyBasedConnector;

var wson = new WSON({ connectors: {
  'Weather': new PropertyBasedConnector(Weather, [ 'temperature', 'pressure', 'humidity', 'sky' ])
  }});

var weather = new Weather('27C', '1000HpA', '75%', 'clear');
console.log(wson.stringify(weather));
// [:Weather|27C|1000Hpa|75%|clear]
```

## License

Copyright &copy; 2016 Maciej Chałapuk.
Released under [MIT license](LICENSE).

