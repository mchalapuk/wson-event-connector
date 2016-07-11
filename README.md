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
var domConnectors = require("wson-dom-connector");
var jsdom = require("jsdom");
var _ = require("underscore");

var window = jsdom.jsdom("<body></body>").defaultView;

var wson = new WSON({
  connectors: _.extend(eventConnectors(window), domConnectors(window))
  });

var body = window.document.body;
body.addEventListener('click', function(event) {
  console.log(wson.stringify(event)));
}
body.dispatchEvent(new window.MouseEvent('click', {
  screenX: 300,
  screenY: 400,
  clientX: 20,
  clientY: 10,
  button: 1,
  buttons: 1,
});
// [:MouseEvent|click|#f|#f|#0|#0|#300|#400|#20|#10|#1|#1|#n|#n|[:HTMLBodyElement|/html`a1`e/body`a1`e]]
```

In order to serialize DOM nodes assigned to event properties (`Event.target`,
`UIEvent.view`, `MouseEvent.relatedTarget`), connectors from
[wson-dom-connector][dom-connector] module must be used.

[dom-connector]: https://github.com/webfront-toolkit/wson-dom-connector

## Supported Events

Following events types are currently supported:

* [`Event`](https://dom.spec.whatwg.org/#interface-event)
  * [`UIEvent`](https://w3c.github.io/uievents/#interface-uievent)
    * [`CompositionEvent`](https://w3c.github.io/uievents/#interface-compositionevent)
    * [`FocusEvent`](https://w3c.github.io/uievents/#interface-focusevent)
    * [`InputEvent`](https://w3c.github.io/uievents/#interface-inputevent)
    * [`KeyboardEvent`](https://w3c.github.io/uievents/#interface-keyboardevent)
    * [`MouseEvent`](https://w3c.github.io/uievents/#interface-mouseevent)
      * [`PointerEvent`](https://w3c.github.io/pointerevents/#pointerevent-interface)
      * [`WheelEvent`](https://w3c.github.io/uievents/#interface-wheelevent)
    * [`TouchEvent`](https://w3c.github.io/touch-events/#idl-def-Touch)
  * [`AnimationEvent`](https://drafts.csswg.org/css-animations/#interface-animationevent)
  * [`BeforeUnloadEvent`](https://dev.w3.org/html5/spec-LC/history.html#beforeunloadevent)
  * [`ClipboardEvent`](https://w3c.github.io/clipboard-apis/#clipboard-event-interfaces)
  * [`CustomEvent`](https://dom.spec.whatwg.org/#interface-customevent)
  * [`FontFaceEvent`](https://wiki.csswg.org/spec/font-load-events)

## (Not Yet) Supported Events

Near future should bring support for following classes:

 * [`DragEvent`](https://html.spec.whatwg.org/multipage/interaction.html#dragevent)
 * [`DeviceOrientationEvent`](https://w3c.github.io/deviceorientation/spec-source-orientation.html#deviceorientation)
 * [`DeviceMotionEvent`](http://w3c.github.io/deviceorientation/spec-source-orientation.html#devicemotion)
 * [`ErrorEvent`](https://html.spec.whatwg.org/multipage/webappapis.html#the-errorevent-interface)
 * [`GamepadEvent`](https://w3c.github.io/gamepad/#gamepadevent-interface)
 * [`HashChangeEvent`](https://html.spec.whatwg.org/multipage/browsers.html#hashchangeevent)
 * [`IDBVersionChangeEvent`](https://www.w3.org/TR/IndexedDB/#idl-def-IDBVersionChangeEvent)
 * [`PageTransitionEvent`](https://html.spec.whatwg.org/multipage/browsers.html#the-pagetransitionevent-interface)
 * [`PopStateEvent`](https://html.spec.whatwg.org/multipage/browsers.html#popstateevent)
 * [`ProgressEvent`](https://xhr.spec.whatwg.org/#interface-progressevent)
 * [`SensorReadingEvent`](https://w3c.github.io/sensors/#the-sensor-reading-event-interface)
 * [`StorageEvent`](https://html.spec.whatwg.org/multipage/webstorage.html#the-storageevent-interface)
 * [`TransitionEvent`](https://drafts.csswg.org/css-transitions/#Events-TransitionEvent)

Feel free to message me if you desperately need one of above.

**Pull requests are also very welcome!**

> **CONTRIBUTING GUIDELINES**:
>
> Please do not submit pull requests implementing non-standard vendor-specific events.
> For those, a separate module should be created (e.g.&nbsp;`wson-mozilla-connector`),
> with this module as dependency (see [API Reference](#api-reference)).

## Unsupported Events

Serialization of following event classes will not be implemented in this module:

 * [`BlobEvent`][blob-event], because [`Blob`][blob]'s content can't be fetched
   from JavaScript,
 * Websockets-related events ([`MessageEvent`][message], [`CloseEvent`][close]).
 * RTC-related events ([`RTCPeerConnectionIceEvent`][rtc-peer-conn-ice],
   [`RTCPeerConnectionIceErrorEvent`][rtc-peer-conn-ice-error],
   [`RTCTrackEvent`][rtc-track], [`RTCDataChannelEvent`][rtc-data-channel],
   [`RTCDTMFToneChangeEvent`][rtc-tone-change]),
 * Service-workers-related event ([`FetchEvent`][fetch],
   [`ExtendableEvent`][extendable], [`ExtendableMessageEvent`][extendable-message]).
 * Web-Audio-related events ([`AudioProcessEvent`][audio-process],
   [`AudioWorkerNodeCreationEvent`][audio-worker-creation],
   [`OfflineAudioCompletionEvent`][offline-audio-completion]),
 * <abbr title="Scalable Vector Graphics">SVG</abbr>-related events ([`TimeEvent`][time],
   [`SVGZoomEvent`][svg-zoom]),
 * WebGL-related events ([`WebGLContextEvent`][webgl-context]).

[blob-event]: https://w3c.github.io/mediacapture-record/MediaRecorder.html#blob-event
[blob]: https://w3c.github.io/FileAPI/#blob
[message]: https://www.w3.org/TR/2012/CR-webmessaging-20120501/#event-definitions
[close]: https://html.spec.whatwg.org/multipage/comms.html#closeevent
[rtc-peer-conn-ice]: https://w3c.github.io/webrtc-pc/#rtcpeerconnectioniceevent
[rtc-peer-conn-ice-error]: https://w3c.github.io/webrtc-pc/#rtcpeerconnectioniceevent
[rtc-track]: https://w3c.github.io/webrtc-pc/#rtctrackevent
[rtc-data-channel]: https://w3c.github.io/webrtc-pc/#rtcdatachannelevent
[rtc-tone-change]: https://w3c.github.io/webrtc-pc/#rtcdtmftonechangeevent
[fetch]: https://www.w3.org/TR/service-workers/#fetch-event-section
[extendable]: https://www.w3.org/TR/service-workers/#extendable-event-interface
[extendable-message]: https://www.w3.org/TR/service-workers/#extendablemessage-event-section
[audio-process]: https://webaudio.github.io/web-audio-api/#the-audioprocessevent-interface
[offline-audio-completion]: https://webaudio.github.io/web-audio-api/#OfflineAudioCompletionEvent
[audio-worker-creation]: https://webaudio.github.io/web-audio-api/#the-audioworkernodecreationevent-interface
[time]: https://www.w3.org/TR/2001/REC-smil-animation-20010904/#Events-TimeEvent
[svg-zoom]: https://www.w3.org/TR/SVG/script.html#InterfaceSVGZoomEvent
[webgl-context]: https://www.khronos.org/registry/webgl/specs/latest/1.0/#5.15

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

## API Reference

This document describes API exported by this (`wson-event-connector`) module.
Please refer to [wson's documentation][wson] for&nbsp;description of wson's API
and serialization algorithm.

### All Connectors

```js
exports = function(window, additionalFields = []) { ... }
```
Creates WSON connectors for all event classes found in **window** namespace.
Created connectors will be extended to&nbsp;serialize fields passed
in **additionalFields** array. Function returns a map
(`event class name => connector instance`), which can be passed
as "connectors" option to WSON's constructor (see example below).

```js
var WSON = require('wson');
var eventConnectors = require('wson-event-connector');

var wson = new WSON({ connectors: eventConnectors(window) });
```

### Event Connector

```js
exports.Event = function(EventClass, additionalFields = []) { ... }
```

Constructs a connector which is able to serialize instances of **EventClass**.
Passed class must be derived from or equal `window.Event`.
Returned connector serializes fields in following order: `Event.bubbles`,
`Event.cancelable`, **additionalFields...**, `Event.target`.

`Event.target` is not settable from JavaScript. Web browsers assign
its value inside `EventTarget.dispatchEvent(event)`.
Events returned from `wson.parse(string)` are not yet dispatched, hence they
do not have `Event.target` set. Instead, target is deserialized into
non-standard **`Event.parsedTarget`** property (see example below).

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

### Init Based Connector

```js
exports.InitBased = function(Class, serializedFields) { ... }
```

Constructs a connector which is able to serialize instances of **Class**.
Class' constructor must accept single argument, which is&nbsp;a map containing
initial values for properties of constructed object (init object pattern?).
Constructed connector serializes fields of names and in order as passed
in **serializedFields** array.

```js
var WSON = require('wson');
var connectors = require('wson-event-connector');

var wson = new WSON({ connectors: {
  'Weather': new connectors.InitBased(Weather, [ 'temperature', 'pressure', 'humidity', 'sky' ])
  }});

var weather = new Weather({
  temperature: '27C',
  pressure: '1000HpA',
  humidity: '75%',
  sky: 'clear'
});
console.log(wson.stringify(weather));
// [:Weather|27C|1000Hpa|75%|clear]
```

## License

Copyright &copy; 2016 Maciej Chałapuk.
Released under [MIT license](LICENSE).

