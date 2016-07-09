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

console.log(wson.stringify(new window.MouseEvent('click')));
// TODO
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

console.log(wson.stringify(new window.MouseEvent('click')));
// TODO
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
 * [`SensorReadingEvent`][sensor-reading-event], as it's not implemented by any
   browser.
 * Non-standard vendor-specific events and properties. These should be
   implemented in separate module (e.g. `wson-mozilla-controller`).
   This module exports many JavaScript classes which simplifies this task
   (check the [source code][code] for details).

[blob-event]: https://developer.mozilla.org/en-US/docs/Web/API/BlobEvent
[blob]: https://developer.mozilla.org/en-US/docs/Web/API/Blob
[sensor-reading-event]: https://w3c.github.io/sensors/#the-sensor-reading-event-interface
[code]: index.js

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

Following documentation contains API's exported by this module.
Please refer to [wson's documentation][wson] for information about wson API.

#### exports `exports(window)`

Creates WSON connectors of all events implemented by this module.

```js
var WSON = require('wson');
var eventConnectors = require('wson-event-connector');

var wson = new WSON({ connectors: eventConnectors(window) };
```

#### Event `exports.Event(EventClass, additionalFields)`

Constructs a connector which is able to serialize event instances of passed
**Class**. Passed class should be derived from `window.Event`. Fields are being
serialized in following order: ***bubbles***, ***cancelable***,
**additionalFields**, ***target***.

`Event.target` property is not settable from JavaScript. A web browser sets this
property to the instance on which `EventTarget.dispatch(event)` was called.
Value of `Event.target` in deserialized event is `null`. Target is deserialized
into non-standard **`Event.parsedTarget`** property.

```js
var WSON = require('wson');
var EventConnector = require('wson-event-connector').EventConnector;

var wson = new WSON({ connectors: {
  'Event': new Event(window.Event)
  }});

var event = wson.parse('[:Event|load|#f|#t|[:HTMLBodyElement|/html`a1`e/body`a1`e]]');
event.parsedTarget.dispatchEvent(event);
```

#### PropertyBasedConnector `exports.PropertyBasedConnector(Class, serializedFields)`

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

