## 0.25.0

-   [Deprecation] `Beacon.createEffect` is renamed to `Beacon.effect`
-   [Deprecation] `Beacon.doBatchUpdate` is renamed to `Beacon.batch`
-   Add `reset` for list,set and map beacons.
-   add `isEmpty` getter that returns true if a lazy beacon is uninitialized.
-   Internal refactor

## 0.24.0

-   [Breaking] Convenience wrapping methods: `.buffer()`, `.bufferTime()`, `.throttle()` and `.filter()` etc no longer needs an initial value. It fetches its initial value from the target beacon if `startNow` is true (which is the default).

## 0.23.0

-   [Breaking] beacon.wrap() no longer returns the wrapper instance. This is redundant as it retuned the same instance that the method was called on. Chanining can be achieved by using `beacon..wrap()..wrap()`

## 0.22.1

-   Add `disposeTogether` option for beacon wrapping. This will dispose all wrapped beacons when the wrapping beacon is disposed and vice versa. It's set the `false` for manual wrapping and `true` when using extension methods like `mybeacon.buffer(10)`

## 0.22.0

-   [Breaking] initialValue is now a named argument for all beacon _classes_. This doesn't affect any existing public api provided by `Beacon.writable()` etc. This only affects you if you are using the `Beacon` class directly.

## 0.21.0

-   [Breaking] Separate `idle` and `loading` states for the `isLoading` getter in `AsyncValue`. Use `isIdleOrLoading` for the old behavior.
-   [Fix] BufferedBeacon.reset() no longer unsubscribes from the wrapped beacon.

## 0.20.1

-   Stacktrace is now optional in AsyncError contructor. StackTrace.current is used if it is not provided.

## 0.20.0

-   [Feat] Add effect actions to Observer and debuglabel for effects.
-   [Feat] A function can be returned from effect closures that will be called when the effect is disposed. This can be used to clean up sub effects.
-   [Fix] Effects no longer do additional passes to discover new beacons when supportCOnditional is false;
-   [Breaking] `isNullable` is no longer exposed
-   [Breaking] remove `reset` from stream and readable beacons.
-   [Breaking] remove `start` from derived beacon. Use late initialization instead.

## 0.19.2

-   [Chore] Update documentation

## 0.19.1

-   [Feat] Add `.next()` to all beacons that exposes the next value as a future
-   [Feat] Add `.buffer()` that returns a [BufferedCountBeacon] that wraps this Beacon.
-   [Feat] Add `.bufferTime()` that returns a [BufferedTimeBeacon] that wraps this Beacon.
-   [Feat] Add `.throttle()` that returns a [ThrottledBeacon] that wraps this Beacon.
-   [Feat] Add `.filter()` that returns a [FilteredBeacon] that wraps this Beacon.

## 0.19.0

-   [Breaking] FamilyBeacon are cached by default

## 0.18.4

-   [Fix] Cached family beacons are removed from cache when they are disposed

## 0.18.3

-   StreamBeacon.reset() now sets loading state and resubscribes to the stream

## 0.18.2

-   [Fix] batch opperations that threw errors would leave the beacon in an inconsistent state.
-   [Breaking] start requests to derived beacons that were already started will now be ignored instead of throwing an error

## 0.18.1

-   [Feature] Make beacons callable(`beacon()`) as an alternative to `beacon.value`

## 0.18.0

-   [Breaking] remove forceSetValue from DerivedBeacon public api

## 0.17.1

-   Make conditional listening configurable for `Beacon.createEffect` ,`Beacon.derived` and `Beacon.derivedFuture`

## 0.17.0

-   Mdd debugLabel to beacons
-   Add BeaconObserver and LoggingObserver classes
-   Add FutureBeacon.overrideWith() to replace the internal callback
-   Add `AsyncValue.isData` and `AsyncValue.isError` getters
-   Add shortcuts: `FutureBeacon.isData` and `FutureBeacon.isError` and `FutureBeacon.unwrapValue()`
-   [Breaking] `AsyncValue.unwrapValue()` is now `AsyncValue.unwrap()`
-   [Breaking] Make initialValue named argument for lazy beacons
-   [Breaking] Make `filter` a named argument for FilteredBeacon
-   [Breaking] Make `initialValue` required for ListBeacon
-   [Breaking] `FutureBeacon.previousValue` is no longer customized to return the previous AsyncData, use `FutureBeacon.lastData` instead

## 0.16.0

-   beacon.toStream() now returns a broadcast stream
-   Add lastData. isLoading and valueOrNull getters to AsyncValue
-   Add optional beacon parameter to tryCatch
-   Add WritableBeacon<AsyncValue>.tryCatch extension for handling asynchronous values

## 0.15.0

-   Beacon.untracked() now only hide the update/access from encompassing effects.

## 0.14.6

-   Add `tryCatch` method to AsyncValue class that executes a future and returns an AsyncData or AsyncError

## 0.14.5

-   Internal improvements

## 0.14.4

-   Add `WriteableBeacon.freeze()` that converts it to a `ReadableBeacon`

## 0.14.3

-   Internal refactor

## 0.14.2

-   Add Beacon.family
-   Add myBeacon.onDispose to listen to when a beacon is disposed
-   Add `onCancel` to `toSteam()` extension method

## 0.14.1

-   internal improvements

## 0.14.0

-   undeRedo: expose canUndo,canRedo and history
-   Add isDisposed property to all beacons
-   Add ThrottleBeacon.setDuration to change the throttle duration

### Breaking Changes

-   Beacon.list no longer implements List. It only has mutating methods

## 0.13.9

-   add `WritableBeacon.clearWrapped()`` method to dispose all currently wrapped beacons

## 0.13.8

-   Revert change in 0.13.7

## 0.13.7

-   Expose the internal completer on FutureBeacon. ie: `myFutureBeacon.completer`

## 0.13.6

-   Minor internal refactor

## 0.13.5

-   Minor internal improvements

## 0.13.4

-   Minor internal refactor

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
