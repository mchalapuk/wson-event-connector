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

## What is Not Serialized?

Following properties are not serialized:

 * Properties, which can be set only in event listener by calling methods
  on event object ([`Event.defaultPrevented`][default-prevented],
  [`Event.cancelBubble`][cancel-bubble]),
 * Properties, which values are set by the browser during an event dispatch
  ([`Event.currentTarget`][current-target], [`Event.eventPhase`][event-phase],
  [`Event.timeStamp`][time-stamp], [`Event.isTrusted`][is-trusted]),
 * [`UIEvent.sourceCapabilities`][source-capabilities], because it's just
  ridiculous to pass the same information in each event.

[default-prevented]: https://developer.mozilla.org/en-US/docs/Web/API/Event/defaultPrevented
[cancel-bubble]: https://developer.mozilla.org/en-US/docs/Web/API/Event/cancelBubble
[current-target]: https://developer.mozilla.org/en-US/docs/Web/API/Event/currentTarget
[event-phase]: https://developer.mozilla.org/en-US/docs/Web/API/Event/eventPhase
[time-stamp]: https://developer.mozilla.org/en-US/docs/Web/API/Event/timeStamp
[is-trusted]: https://developer.mozilla.org/en-US/docs/Web/API/Event/isTrusted
[source-capabilities]: https://developer.mozilla.org/en-US/docs/Web/API/UIEvent/sourceCapabilities

Serialization of following event classes is not implemented in this module:

 * [`BlobEvent`][blob-event], because [`Blob`][blob]'s content can't be fetched
   from JavaScript.

[blob-event]: https://developer.mozilla.org/en-US/docs/Web/API/BlobEvent
[blob]: https://developer.mozilla.org/en-US/docs/Web/API/Blob

## API
Please refer to [wson's documentation][wson] for further details.

## License

Copyright &copy; 2016 Maciej Chałapuk.
Released under [MIT license](LICENSE).
