## 0.13.3

-   Internal improvements

## 0.13.2

-   Internal improvements

## 0.13.1

-   Internal improvements

## 0.13.0

-   `watch` and `observe` are now methods on Beacon instead of extensions

## 0.12.11

-   Add FilteredBeacon.hasFilter getter
-   Fix previous Value in filteredBeacon filter callback

## 0.12.10

-   Add Beacon.untracked

## 0.12.9

-   Internal improvements

## 0.12.8

-   Fix null assertion bug in `Beacon.observe`

## 0.12.7

-   Add beacon.observe(context, callback) for performing side effects in a widget

## 0.12.6

-   TimestampBeacon now extend ReadableBeacon

## 0.12.5

-   Internal code refactor

## 0.12.4

-   Internal improvements

## 0.12.3

-   Internal fixes

## 0.12.2

-   Add myStreamBeacon.toFuture() that exposes a StreamBeacon as a Future
-   Add Beacon.streamRaw that emits unwrapped values

## 0.12.1

-   Internal fixes

## 0.12.0

-   Beacon.asFuture is now FutureBeacon.toFuture()

## 0.11.2

-   Add Beacon.asFuture that exposes a FutureBeacon as a Future

## 0.11.1

-   Mark internal methods as @protected

## 0.11.0

-   FutureBeacon is now a base class for DefaultFutureBeacon and DerivedFutureBeacon
-   Expose DerivedFutureBeacon as a FutureBeacon

## 0.10.2

-   Add unwrapValue() method to AsyncValue class
-   Keep track of the last AsyncData so it can be used in loading and error states

## 0.10.1

-   Expose listenersCount
-   Internal improvements

## 0.10.0

-   FilteredBeacon : Make filter function nullable which allows changing/setting it after initialization

## 0.9.2

-   Fix: refreshing logic for DerivedFutureBeacon
-   Allow customization of how the old results of a future are handled in when it has be retriggered
-   Add increment and decrement methods to Writable<num>

## 0.9.1

-   Add initialValue getter
-   Customize previousValue getter for DerivedFutureBeacon to ignore loading/error states
-   Fix memory leak in BufferedBeacons

## 0.9.0

-   Roll flutter_state_beacon package into state_beacon package
-   Add `watch` extension for use in flutter widgets
-   Beacons now implement ValueListenable
-   Add `toValueNotifier()` and `toStream()` extension methods

## 0.8.0

-   Avoid throwing errors when start is called on a beacon that is already started

## 0.7.0

-   Changed `startNow` to `manualStart` for future and derived beacons to avoid ambiguity

## 0.6.1

-   Expose `cancelOnError` option for StreamBeaon

## 0.6.0

-   Give all writable beacons a lazy variant
-   Expose option to manually trigger futureBeacon execution
-   Add option to manually trigger and reset derivedFutureBeacon
-   Add option to manually trigger derivedBeacon
-   Refactor Writable.wrap and remove redundant methods: wrapThen and wrapTransform
-   Add BufferedBeacon.wrap

## 0.5.0

-   Add AsyncIdle State and ability to manually trigger futureBeacon execution
-   Add ability to do lazy starts for wrap methods

## 0.4.1

-   Internal refactor

## 0.4.0

-   Add WritableBeacon.set that can force update listeners

## 0.3.3

-   Expose all Beacons

## 0.3.2

-   Expose ReadableBeacon and WritableBeacon

## 0.3.1

-   ThrottledBeacon: add method to change duration
-   Add Writable.wrapThen
-   Return dispose function for all `wrap` method

## 0.3.0

-   Expose currentBuffer for BufferedCountBeacon and BufferedTimeBeacon
-   Fix bug in BufferedTimeBeacon.reset()
-   Add UndoRedoBeacon

## 0.2.1

-   Add BufferedCountBeacon and BufferedTimeBeacon

## 0.2.0

-   Fix bug with DerivedBeacons unregistering
-   Notify listeners when LazyBeacon is initialized
-   Add `mapInPlace` for ListBeacon

## 0.1.2

-   Add `Beacon.scopedWritable`.

## 0.1.1

-   Update pubspec.yaml.

## 0.1.0

-   Initial version.
