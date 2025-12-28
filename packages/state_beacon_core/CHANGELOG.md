# 2.0.2

-[Fix] Nullable derived beacons didn't send notifications in some instances.

# 2.0.1

- [Refactor] Internal efficiency refactor.

# 2.0.0

- [Breaking] `anyBeacon.toStream()` is now `anyBeacon.stream`

- [Breaking] The lazyBypass parameter in `.filter()` chain method was replaced with allowFirst (set to false by default).

    Previously, the first value sent to a lazy filtered beacon would not be filtered as `lazyBypass` was `true` by default. This caused confusion as most persons expect it to be filtered. The name of the parameter has been changed to `allowFirst` and it is set to `false` by default.

    ### OLD
    ```
    final count = Beacon.writable(0);
    final gtThan10 = count.filter((prev,next) => next>10);

    expect(gtThan10.peek(), 0); // first value was set immediately
    ```

    ### NEW
    ```
    final count = Beacon.writable(0);
    final gtThan10 = count.filter((prev,next) => next>10);

    expect(gtThan10.peek, throwsException) // no value has been set as yet

    count.value = 20;

    await gtThan10.next();

    expect(d.peek(), 20) // value set after passing the filter
    ```

- [Breaking]  Added allowFirst parameter to lazyDebounced and `.debounce()` chain method (set to false by default)

    Previously, the first value sent to a lazy debounced beacon would not be debounced. It is now debounced by default and you can allow the first value to go through by setting `allowFirst` to `true`.

    ### OLD
    ```
    final ms500 = Duration(milliseconds:500);
    final count = Beacon.writable(0);
    final d = count.debounce(ms500);

    expect(d.peek(), 0); // first value was set immediately
    ```

    ### NEW
    ```
    final ms500 = Duration(milliseconds:500);
    final count = Beacon.writable(0);
    final d = count.debounce(ms500);

    expect(d.peek, throwsException) // no value has been set as yet

    await Future.delayed(ms500*2);

    expect(d.peek(), 0) // value set after being debounced
    ```

- [Breaking] synchronous parameter has been removed from the `.subscribe()` method. Synchronous subscriptions are only available for `Writable` and `Buffered` beacons through the `.subscribeSynchronously()` method.

- [Breaking] Chaining methods are now asynchronous and return immutable beacons. ie: `map`, `filter`, `debounce`, `throttle`, `buffer`, and `bufferTime`. 

    These being writable complicated the codebase as writes had to be rerouted to the first mutable beacon in the chain. The alternative is to mutate the original beacon directly.


# 1.3.4

- [Fix] synchronous subscription RangeError when disposed in it's callback.

# 1.3.3

- [Deprecate] deprecate supportConditional parameter in effect methods. This param was already ignored in v0.34.0 but wasn't marked as deprecated
- [Fix] forced writes to throttled beacons incorrectly dropped the `force` flag when those writes were added to the buffer.
- [Fix] Map.remove,List.remove and Set.remove no longer notifies listerners when nothing was removed.
- [Fix] previousValue was incorrectly set when using lazy beacons
- [Fix] Edge case where a subscription to a derived beacon with startNow=false would run immediately


# 1.3.2

-   [Fix] Minor improvement by removing internal redundant method call

# 1.3.1

-   [Fix] Chaining methods on derived beacons now eagerly fetches the value allowing it to be used instantly.

```dart
final count = Beacon.writable<int>(0);

final throttled = Beacon.derived(() => count.value * 2).throttle(k10ms);

expect(throttled.value, 0);
```

# 1.3.0

-   [Feat] Add queuing to FutureBeacon.updateWith()
    The `updateWith` method calls are now queued when there is an ongoing update. This ensures that all calls are executed in the order they were made, preventing race conditions and inconsistent state.

# 1.2.0

-   [Feat] Add `Future.updateWith()`

The `updateWith` method allows you to update a FutureBeacon's value with the provided callback. This differs from `overrideWith` because it updates the value only once, while `overrideWith` replaces the original callback supplied to the beacon.

```dart
Future<List<Todo>> loadTodos() async { ... }

Future<List<Todo>> addTodo(Todo newTodo) async {
  await todoService.addTodo(newTodo);
  final currentTodos = todosBeacon.lastData ?? [];
  return [newTodo, ...currentTodos];
}

final todosBeacon = Beacon.future(() => loadTodos());

// Later, add a new todo without refetching all todos
await todosBeacon.updateWith(() => addTodo(newTodo));

// You can also provide an optimistic result
// which will be set immediately while the future is being resolved.
final optimisticTodos = [newTodo, ...todosBeacon.lastData ?? []];
await todosBeacon.updateWith(
  () => addTodo(newTodo),
  optimisticResult: optimisticTodos,
);
```

# 1.1.0

-   [Feat] Derived Beacons can now access their own value with '.peek()'. The beacon must have a value so a base case is required.

```dart
final counter = Beacon.writable(0);

late final ReadableBeacon<int> accumulated;

accumulated = Beacon.derived(() {
    final count = counter.value;

    if (count == 0) {
        return 0; // base case
    }
    return accumulated.peek() + counter.value;
});
```

# 1.0.2

-   [Refactor] Minor performance improvements.

# 1.0.1

-   Bug Fix: Flutter edge-case for derivedBeacons. This was fixed before but the current fix is more efficient.

# 1.0.0

-   Stable release

# 0.43.6

-   [Fix] Edge case for Subscriptions

# 0.43.5

-   BeaconGroup.add(anybeacon) to add a beacon a group

# 0.43.4

-   [Fix] Fix bug with `FutureBeacon`s not autosleeping
-   [Feat] Expose list of beacons created in a BeaconGroup wuth `BeaconGroup.beacons`
-   [Feat] Add `BeaconGroup.onCreate` to allow adding a callback to be run when a beacon is created

# 0.43.3

-   [Fix] Rare bug in FutureBeacon when start is called multiple times synchronously.

# 0.43.2

-   [Feat] Add `FutureBeacon.idle()` to set a beacon to the `AsyncIdle` state.

# 0.43.1

-   [Refactor] Internal refactor

# 0.43.0

-   [Breaking] The `beacons` getter for `Beacon.family` has been replaced with `entries`. This is a breaking change because it returns a `MapEntry<Key,Beacon>` instead of a `Beacon`.

# 0.42.1

-   [Fix] Export PeriodicBeacon and BeaconFamily classes

# 0.42.0

-   [Breaking] `resetIfError` option for `toFuture()` is now `true` by default. This was done because there's rarely a case where you'd want it to throw instantly. If you want to keep the previous value, set `resetIfError` to `false`.

# 0.41.2

-   [Docs] Update README

# 0.41.1

-   [Refactor] Move `BeaconController` to `state_beacon_core` package

# 0.41.0

-   [Feat] Add `Beacon.periodic` that emits values periodically.

    ```dart
    final myBeacon = Beacon.periodic(Duration(seconds: 1), (i) => i + 1);

    final nextFive = await myBeacon.buffer(5).next();

    expect(nextFive, [1, 2, 3, 4, 5]);
    ```

-   [Breaking] `FutureBeacon.toFuture()` now returns immediately when it's not in the loading state. This is breaking because in previous versions, it would wait for the next update before returning the value. This was a bug! To get the next state you can use `.next()`.
-   [Feat] `FutureBeacon.toFuture()` now has a `resetIfError` option that will reset the beacon if the current state is `AsyncError`.

# 0.40.0

-   [Feat] Add `BeaconController` for use in Flutter. see [docs](https://github.com/zupat/dart_beacon/blob/main/packages/state_beacon/README.md#beaconcontroller)
-   [Feat] Implement `Disposable` from [basic_interfaces](https://pub.dev/packages/basic_interfaces) package which makes it autodispsable when used with the [lite_ref](https://pub.dev/packages/lite_ref) package.
-   [Docs] Add section on `testing` to the README.
-   [Feat] Add `synchronous` option to wrap and chaining methods. This defaults to `true` which means that wrapper beacons will get all updates.
-   [Breaking] Duration is now a positional argument for chaining methods `yourBeacon.debounce()`, `yourBeacon.throttle()`, `yourBeacon.bufferTime()`. This was done to make the code more concise.

    -   Old:

    ```dart
    final myBeacon = Beacon.writable(0);
    myBeacon.debounce(duration: k10ms);
    myBeacon.throttle(duration: k10ms);
    myBeacon.bufferTime(duration: k10ms);
    ```

    -   New:

    ```dart
    final myBeacon = Beacon.writable(0);
    myBeacon.debounce(k10ms);
    myBeacon.throttle(k10ms);
    myBeacon.bufferTime(k10ms);
    ```

-   [Deprecation] `yourBeacon.stream` is now `yourBeacon.toStream()`. This was done to allow auto-batching configuration. By default, auto-batching is enabled. You can disable it by setting `synchronous` to `true`.

    -   Old:

    ```dart
    final myBeacon = Beacon.writable(0);
    myBeacon.stream;
    ```

    -   New:

    ```dart
    final myBeacon = Beacon.writable(0);
    myBeacon.toStream();
    ```

# 0.39.1

-   Minor refactor to improve performance.
-   Add `BeaconObserver.useLogging()` as an alias to `BeaconObserver.instance = LoggingObserver()`.
-   Reduce sdk constraint to ^3.0.0 from ^3.1.5

# 0.39.0

-   [Breaking] Beacons will no longer be reset when disposed. It will keep its current value.
-   [Breaking] Writing to a disposed beacon will throw an error. Reading will print a warning to the console in debug mode. A beacon should only be disposed if you have no more use for it. If you want to reuse a beacon, use the `reset` method instead.

    ```dart
    final a = Beacon.writable(10);
    a.dispose();
    a.value = 20; // throws an error
    print(a.value); // prints 10
    ```

-   [Breaking] When a beacon is disposed, all downstream derived beacons and effects will be disposed as well.

    ```dart
    final a = Beacon.writable(10);
    final b = Beacon.writable(10);
    final c = Beacon.derived(() => a.value * b.value);

    a.subscribe((_) {});

    Beacon.effect(
        () {
        c.value;
        },
        name: 'effect',
    );

    //...//

    a.dispose();

    // "c" is watching "a" so it is disposed
    // the effect is watching "c" so it is disposed
    //
    // a   b
    // |  /
    // | /
    // c
    // |
    // effect

    expect(a.isDisposed, true);
    expect(c.isDisposed, true);
    // effect is also disposed
    ```

# 0.38.0

-   [Feat] Add methods to `Beacon.streamRaw` that operates on the internal stream: `unsubscribe` `pause` and `resume`.
-   [Feat] `onDispose` now returns a function that can be used to unregister the dispose listener.
-   [Breaking] `anybeacon.next()` no longer takes a timeout parameter. It will also throw an error if called on a lazy beacon and the beacon is disposed before emitting a value; unless a [fallback] value is provided.

Removed Deprecated methods:
`anybeacon.toStream()` is now removed. Use `anybeacon.stream` instead.

# 0.37.0

-   [Breaking] Remove `unsubscribe` method from `Beacon.streamRaw`
-   [Fix] Bug when using Flutter scheduler where effects were not running before `runApp` was called.
-   [Refactor] Internal refactor

# 0.36.0

-   [Breaking] `Beacon.stream` and `Beacon.streamRaw` will now autosleep when they have no more listeners. This is a breaking change because it changes the default behavior. If you want to keep the old behavior, set `shouldSleep` to false.

They will unsubscribe from the stream when sleeping and resubscribe when awoken. For `Beacon.stream`, it will enter the loading state when awoken. It is recommended to use the default when using services like Firebase to prevent cost overruns.

# 0.35.0

-   [Breaking] The filter function is now required when chaining the filtered beacon.

### old:

```dart
final count = Beacon.writable(10);
final filtered = count.filter(filter: (prev, next) => next.isEven);
```

### new:

```dart
final count = Beacon.writable(10);
final filtered = count.filter((prev, next) => next.isEven);
```

# 0.34.4

-   Internal refactor

# 0.34.3

-   [Feat] Add `map` to chaining methods

```dart
final count = Beacon.writable(10);
final mapped = count.map((value) => value * 2);

expect(mapped.value, 20);

count.value = 20;

expect(count.value, 20);
expect(mapped.value, 40);
```

```dart
final stream = Stream.periodic(k1ms, (i) => i).take(5);
final beacon = stream
        .toRawBeacon(isLazy: true)
        .filter((_, n) => n.isEven)
        .map((v) => v + 1)
        .throttle(duration: k1ms);

await expectLater(beacon.stream, emitsInOrder([1, 3, 5]));
```

See [docs](https://github.com/zupat/dart_beacon?tab=readme-ov-file#mybeaconmap) for more information.

# 0.34.2

-   [Feat] Expose the list of beacons as a `Readable<List<BeaconType>>` in the family beacon's cache.

    ```dart
    final myFamily = Beacon.family((int id) => Beacon.writable(0));
    final beacons1 = family(1);

    Beacon.effect((){
        print('cache updated: ${myFamily.beacons.value}');
    });

    final beacons2 = family(2);
    // prints: cache updated: [beacons1, beacons2]
    ```

# 0.34.1

-   [Refactor] Internal refactor and minor improvement in performance

# 0.34.0

-   [Breaking] `Beacon.stream` and `Beacon.streamRaw` now takes a function that returns a stream instead of a stream directly. The upside of this change is that they are now derived beacons. All beacons accessed in the function will be tracked as dependencies. This means that if one of their dependencies changes, it will unsubscribe from the old stream and subscribe to the new one. This is a breaking change because it changes the signature of the method.

-   [Feat] Use can now manually start a stream beacon. It will start in the idle state when `manualStart` is true.

-   [Deprecated] `Beacon.derivedStream` is now deprecated. Use `Beacon.streaRaw` instead.
-   [Deprecated] `Beacon.derivedFuture` is now deprecated. Use `Beacon.future` instead.
-   [Deprecated] `Beacon.batch` is now deprecated. Batching is automatic with the [new core](#new-core).
-   [Breaking] `cancelRunning` is now removed from `FutureBeacon`. It is now the default behavior.

## New Core:

This is a major update with many breaking changes. The core of state_beacon was rewritten from scratch to be more efficient and to support more use-cases.

Pros:

-   Automatic batching
-   Asynchronous by default
-   Better performance for deep dependency trees/circular dependencies
-   Scheduler customization
    A scheduler is just a function that decides when to run all queued effects(flushing). By default, flushing is done with a microtask from DARTVM. This can be customized depending on your use case. For example, the flutter package ships with a scheduler that uses flutter's SchedulerBinding to handle flushing; as well as a 60fps scheduler that limits flushing to 60 times per second. Here is how you'd use them

```dart
BeaconScheduler.useFlutterScheduler();
BeaconScheduler.use60fpsScheduler();
```

For flutter apps, it's recommended to use the flutter scheduler. The method must be called in the main function of your app.

```dart
void main() {
 BeaconScheduler.useFlutterScheduler();

 runApp(const MyApp());
}
```

Cons:

-   Default asynchrony introduces an inconvenience with testing. Effects are queued and the scheduler decides when to flush the queue. This is ideal for apps but makes testing harder because you have to manually flush the effect queue after updating a beacon to run all effects that depends on it. This can be done by calling `BeaconScheduler.flush()` after updating the beacon.

> [!NOTE]  
> This only applies to pure dart tests. In widgets tests, calling `tester.pumpAndSettle()` will flush the queue.

```dart
final a = Beacon.writable(10);
var called = 0;

// effect is queued for execution. The scheduler decides when to run the effect
Beacon.effect(() {
      print("current value: ${a.value}");
      called++;
});

// manually flush the queue to run the all effect immediately
BeaconScheduler.flush();

expect(called, 1);

a.value = 20; // effect will be queued again.

BeaconScheduler.flush();

expect(called, 2);
```

# 0.33.6

-   [Fix] Add bug fix from 0.34.0 to flutter package

# 0.33.5

-   [Fix] Bug with auto sleeping derivedFuture beacons

# 0.33.4

-   [Fix] Concurrent modification error when notifying listeners.

# 0.33.3

-   Allow a duration to be null in `ThrottledBeacon` and `DebouncedBeacon` to disable the throttle/debouncing. This makes them easier to test.

# 0.33.2

-   [Feat] Add `Beacon.derivedStream`

Specialized `DerivedBeacon` that subscribes to the stream returned from its callback and updates its value based on the emitted values.
When a dependency changes, the beacon will unsubscribe from the old stream and subscribe to the new one.

Example:

```dart
final userID = Beacon.writable<int>(18235);
final profileBeacon = Beacon.derivedStream(() {
 return getProfileStreamFromUID(userID.value);
});
```

# 0.33.1

-   [Fix] All delegated writes will be forced to account for the fact that rollback isn't possible.

# 0.33.0

-   [Feat] Chaining beacons is now supported. When the beacon returned from a chain is mutated, the mutation is re-routed to the first beacon in the chain.

```dart
final query = Beacon.writable('');

const k500ms = Duration(milliseconds: 500);

final debouncedQuery = query
        .filter((prev, next) => next.length > 2)
        .debounce(duration: k500ms);
```

When `debouncedQuery` is mutated, the mutation is re-routed to `query`, then `filter` and finally `debounce`.

NB: Buffered beacons cannot be mid-chain. If they are used, they must be the last beacon in the chain.

```dart
// GOOD
someBeacon.filter().buffer(10);

// BAD
someBeacon.buffer(10).filter();
```

# 0.32.2

-   Allow `initialValue` to be passed to `ingest` method

# 0.32.1

-   [Feat] Any writable can now wrap a stream with the new .ingest() method.

    ```dart
    final myBeacon = Beacon.writable(0);
    myBeacon.ingest(anyStream);
    ```

-   [Feat] `RawStreamBeacon`s can now be initialized lazily by setting the `isLazy` option to true.

# 0.32.0

-   [Feat] Add `.stream` getter for all beacons
-   [Deprecation] `toStream()` is now deprecated. Use `.stream` instead.

    ```dart
    // before
    final myBeacon = Beacon.writable(0);
    final myStream = myBeacon.toStream();

    // after
    final myBeacon = Beacon.writable(0);
    final myStream = myBeacon.stream;
    ```

# 0.31.2

-   [Perf] This is an internal change. Only create 1 `StreamController` per beacon.
-   [Deprecation] The `broadcast` option for `toStream()` is now deprecated as it's now redundant.

    ```dart
    // before
    final myBeacon = Beacon.writable(0);
    final myStream = myBeacon.toStream(broadcast: true);

    // after
    final myBeacon = Beacon.writable(0);
    final myStream = myBeacon.toStream();
    ```

# 0.31.1

-   [Fix] mirror force option of wrapped beacons.

# 0.31.0

-   [Breaking] Derived and DerivedFuture beacons will now enter a sleep state when a widget/effect watching it is unmounted/disposed.

    Currently derived & derivedFuture beacons always execute even if it has no listeners.
    It will now enter a sleep state when nothing is watching it.

    Pro: No unneeded computation so it saves battery life.
    Con: It will not have the latest state when a widget starts watching it again so it will be in the loading state when woken up.

    It is configurable with a `shouldSleep` option which defaults to true.

    NB: It still start eagerly, the above only kicks in when listeners decrease from 1 to 0. If you want a lazy start, just declare it as a late variable.

    ```dart
    // with late keyword, someFuture won't run until stats is used.
    late final stats = Beacon.derivedFuture(() async => someFuture());
    ```

# 0.30.0

-   [Feat] Add BeaconGroup that allows you to group beacons together and dispose/reset them all at once.

    ```dart
    final myGroup = BeaconGroup();

    final name = myGroup.writable('Bob');
    final age = myGroup.writable(20);

    age.value = 21;
    name.value = 'Alice';

    myGroup.resetAll();

    print(name.value); // Bob
    print(age.value); // 20

    myGroup.disposeAll();

    print(name.isDisposed); // true
    print(age.isDisposed); // true
    ```

-   [Fix] resetting an uninitialized lazybeacon no longer throws an error.

# 0.29.3

-   [Feat] Add ability to do optimistic update when using AsyncValue.tryCatch()

# 0.29.2

-   Internal refactor that enables deeply nested untracked withing nested effects. This is just covers a rare edge case and should not affect any existing code.

# 0.29.1

-   [Refactor] Internal refactor to improve performance

# 0.29.0

-   [Breaking] `toStream()` now has a broadcast option that defaults to false. This is a breaking change because it changes the default behavior of `toStream()`. If you want to keep the old behavior, set `broadcast` to true.

# 0.28.0

-   Internal refactor

# 0.27.0

-   [Breaking] rename `debugLabel` to `name`

# 0.26.0

-   [Breaking] beacons **NO** longer implements ValueListenable. Use `mybeacon.toListenable()` as a replacement. This was done because implementing ValueListenable necessitated importing the flutter package which isn't usable in pure dart projects.

## Everything below was written before the state_beacon -> state_beacon_core migration

The core of state_beacon was extracted into a separate package to make it usuable in pure dart projects.

# 0.25.0

-   [Deprecation] `Beacon.createEffect`. Use `Beacon.effect` instead.
-   [Deprecation] `Beacon.doBatchUpdate`. Use `Beacon.batch` instead.
-   Add `reset` for list,set and map beacons.
-   add `isEmpty` getter that returns true if a lazy beacon is uninitialized.
-   Internal refactor

# 0.24.0

-   [Breaking] Convenience wrapping methods: `.buffer()`, `.bufferTime()`, `.throttle()` and `.filter()` etc no longer needs an initial value. It fetches its initial value from the target beacon if `startNow` is true (which is the default).

# 0.23.0

-   [Breaking] beacon.wrap() no longer returns the wrapper instance. This is redundant as it retuned the same instance that the method was called on. Chanining can be achieved by using `beacon..wrap()..wrap()`

# 0.22.1

-   Add `disposeTogether` option for beacon wrapping. This will dispose all wrapped beacons when the wrapping beacon is disposed and vice versa. It's set the `false` for manual wrapping and `true` when using extension methods like `mybeacon.buffer(10)`

# 0.22.0

-   [Breaking] initialValue is now a named argument for all beacon _classes_. This doesn't affect any existing public api provided by `Beacon.writable()` etc. This only affects you if you are using the `Beacon` class directly.

# 0.21.0

-   [Breaking] Separate `idle` and `loading` states for the `isLoading` getter in `AsyncValue`. Use `isIdleOrLoading` for the old behavior.
-   [Fix] BufferedBeacon.reset() no longer unsubscribes from the wrapped beacon.

# 0.20.1

-   Stacktrace is now optional in AsyncError contructor. StackTrace.current is used if it is not provided.

# 0.20.0

-   [Feat] Add effect actions to Observer and debuglabel for effects.
-   [Feat] A function can be returned from effect closures that will be called when the effect is disposed. This can be used to clean up sub effects.
-   [Fix] Effects no longer do additional passes to discover new beacons when supportCOnditional is false;
-   [Breaking] `isNullable` is no longer exposed
-   [Breaking] remove `reset` from stream and readable beacons.
-   [Breaking] remove `start` from derived beacon. Use late initialization instead.

# 0.19.2

-   [Chore] Update documentation

# 0.19.1

-   [Feat] Add `.next()` to all beacons that exposes the next value as a future
-   [Feat] Add `.buffer()` that returns a [BufferedCountBeacon] that wraps this Beacon.
-   [Feat] Add `.bufferTime()` that returns a [BufferedTimeBeacon] that wraps this Beacon.
-   [Feat] Add `.throttle()` that returns a [ThrottledBeacon] that wraps this Beacon.
-   [Feat] Add `.filter()` that returns a [FilteredBeacon] that wraps this Beacon.

# 0.19.0

-   [Breaking] FamilyBeacon are cached by default

# 0.18.4

-   [Fix] Cached family beacons are removed from cache when they are disposed

# 0.18.3

-   StreamBeacon.reset() now sets loading state and resubscribes to the stream

# 0.18.2

-   [Fix] batch opperations that threw errors would leave the beacon in an inconsistent state.
-   [Breaking] start requests to derived beacons that were already started will now be ignored instead of throwing an error

# 0.18.1

-   [Feature] Make beacons callable(`beacon()`) as an alternative to `beacon.value`

# 0.18.0

-   [Breaking] remove forceSetValue from DerivedBeacon public api

# 0.17.1

-   Make conditional listening configurable for `Beacon.createEffect` ,`Beacon.derived` and `Beacon.derivedFuture`

# 0.17.0

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

# 0.16.0

-   beacon.toStream() now returns a broadcast stream
-   Add lastData. isLoading and valueOrNull getters to AsyncValue
-   Add optional beacon parameter to tryCatch
-   Add WritableBeacon<AsyncValue>.tryCatch extension for handling asynchronous values

# 0.15.0

-   Beacon.untracked() now only hide the update/access from encompassing effects.

# 0.14.6

-   Add `tryCatch` method to AsyncValue class that executes a future and returns an AsyncData or AsyncError

# 0.14.5

-   Internal improvements

# 0.14.4

-   Add `WriteableBeacon.freeze()` that converts it to a `ReadableBeacon`

# 0.14.3

-   Internal refactor

# 0.14.2

-   Add Beacon.family
-   Add myBeacon.onDispose to listen to when a beacon is disposed
-   Add `onCancel` to `toSteam()` extension method

# 0.14.1

-   internal improvements

# 0.14.0

-   undeRedo: expose canUndo,canRedo and history
-   Add isDisposed property to all beacons
-   Add ThrottleBeacon.setDuration to change the throttle duration

### Breaking Changes

-   Beacon.list no longer implements List. It only has mutating methods

# 0.13.9

-   add `WritableBeacon.clearWrapped()`` method to dispose all currently wrapped beacons

# 0.13.8

-   Revert change in 0.13.7

# 0.13.7

-   Expose the internal completer on FutureBeacon. ie: `myFutureBeacon.completer`

# 0.13.6

-   Minor internal refactor

# 0.13.5

-   Minor internal improvements

# 0.13.4

-   Minor internal refactor

# 0.13.3

-   Internal improvements

# 0.13.2

-   Internal improvements

# 0.13.1

-   Internal improvements

# 0.13.0

-   `watch` and `observe` are now methods on Beacon instead of extensions

# 0.12.11

-   Add FilteredBeacon.hasFilter getter
-   Fix previous Value in filteredBeacon filter callback

# 0.12.10

-   Add Beacon.untracked

# 0.12.9

-   Internal improvements

# 0.12.8

-   Fix null assertion bug in `Beacon.observe`

# 0.12.7

-   Add beacon.observe(context, callback) for performing side effects in a widget

# 0.12.6

-   TimestampBeacon now extend ReadableBeacon

# 0.12.5

-   Internal code refactor

# 0.12.4

-   Internal improvements

# 0.12.3

-   Internal fixes

# 0.12.2

-   Add myStreamBeacon.toFuture() that exposes a StreamBeacon as a Future
-   Add Beacon.streamRaw that emits unwrapped values

# 0.12.1

-   Internal fixes

# 0.12.0

-   Beacon.asFuture is now FutureBeacon.toFuture()

# 0.11.2

-   Add Beacon.asFuture that exposes a FutureBeacon as a Future

# 0.11.1

-   Mark internal methods as @protected

# 0.11.0

-   FutureBeacon is now a base class for DefaultFutureBeacon and DerivedFutureBeacon
-   Expose DerivedFutureBeacon as a FutureBeacon

# 0.10.2

-   Add unwrapValue() method to AsyncValue class
-   Keep track of the last AsyncData so it can be used in loading and error states

# 0.10.1

-   Expose listenersCount
-   Internal improvements

# 0.10.0

-   FilteredBeacon : Make filter function nullable which allows changing/setting it after initialization

# 0.9.2

-   Fix: refreshing logic for DerivedFutureBeacon
-   Allow customization of how the old results of a future are handled in when it has be retriggered
-   Add increment and decrement methods to Writable<num>

# 0.9.1

-   Add initialValue getter
-   Customize previousValue getter for DerivedFutureBeacon to ignore loading/error states
-   Fix memory leak in BufferedBeacons

# 0.9.0

-   Roll flutter_state_beacon package into state_beacon package
-   Add `watch` extension for use in flutter widgets
-   Beacons now implement ValueListenable
-   Add `toValueNotifier()` and `toStream()` extension methods

# 0.8.0

-   Avoid throwing errors when start is called on a beacon that is already started

# 0.7.0

-   Changed `startNow` to `manualStart` for future and derived beacons to avoid ambiguity

# 0.6.1

-   Expose `cancelOnError` option for StreamBeaon

# 0.6.0

-   Give all writable beacons a lazy variant
-   Expose option to manually trigger futureBeacon execution
-   Add option to manually trigger and reset derivedFutureBeacon
-   Add option to manually trigger derivedBeacon
-   Refactor Writable.wrap and remove redundant methods: wrapThen and wrapTransform
-   Add BufferedBeacon.wrap

# 0.5.0

-   Add AsyncIdle State and ability to manually trigger futureBeacon execution
-   Add ability to do lazy starts for wrap methods

# 0.4.1

-   Internal refactor

# 0.4.0

-   Add WritableBeacon.set that can force update listeners

# 0.3.3

-   Expose all Beacons

# 0.3.2

-   Expose ReadableBeacon and WritableBeacon

# 0.3.1

-   ThrottledBeacon: add method to change duration
-   Add Writable.wrapThen
-   Return dispose function for all `wrap` method

# 0.3.0

-   Expose currentBuffer for BufferedCountBeacon and BufferedTimeBeacon
-   Fix bug in BufferedTimeBeacon.reset()
-   Add UndoRedoBeacon

# 0.2.1

-   Add BufferedCountBeacon and BufferedTimeBeacon

# 0.2.0

-   Fix bug with DerivedBeacons unregistering
-   Notify listeners when LazyBeacon is initialized
-   Add `mapInPlace` for ListBeacon

# 0.1.2

-   Add `Beacon.scopedWritable`.

# 0.1.1

-   Update pubspec.yaml.

# 0.1.0

-   Initial version.