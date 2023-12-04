## 0.6.0

-   Give all writable beacons a lazy variant
-   Expose option to manually trigger futureBeacon execution
-   Add option to manually trigger and reset derivedFutureBeacon
-   Add option to manually trigger derivedBeacon

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
