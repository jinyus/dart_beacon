<p align="center">
  <img width="650" src="https://github.com/jinyus/dart_beacon/blob/main/assets/state_beacon_banner.jpeg?raw=true">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-purple"> 
  <a href="https://app.codecov.io/github/jinyus/dart_beacon"><img src="https://img.shields.io/codecov/c/github/jinyus/dart_beacon"></a>
  <a href="https://pub.dev/packages/state_beacon"><img src="https://img.shields.io/pub/points/state_beacon?color=blue"></a>
</p>

## Overview

A Beacon is a reactive primitive(`signal`) and simple state management solution for Dart and Flutter.

Flutter web demo([source](https://github.com/jinyus/dart_beacon/tree/main/examples/flutter_main/lib)): https://flutter-beacon.surge.sh/
<br>All examples: https://github.com/jinyus/dart_beacon/tree/main/examples

<p align="center">
  <img src="https://github.com/jinyus/dart_beacon/blob/main/assets/state_beacon_demo.jpg?raw=true">
</p>

## Installation

```bash
dart pub add state_beacon
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:state_beacon/state_beacon.dart';

final name = Beacon.writable("Bob");

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    // rebuilds whenever the name changes
    return Text(name.watch(context));
  }
}
```

#### Using an asynchronous function

```dart
final counter = Beacon.writable(0);

// The future will be recomputed whenever the counter changes
final futureCounter = Beacon.future(() async {
  final count = counter.value;
  return await fetchData(count);
});

Future<String> fetchData(int count) async {
  await Future.delayed(Duration(seconds: count));
  return '$count second has passed.';
}

class FutureCounter extends StatelessWidget {
  const FutureCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (futureCounter.watch(context)) {
      AsyncData<String>(value: final v) => Text(v),
      AsyncError(error: final e) => Text('$e'),
      _ => const CircularProgressIndicator(),
    };
  }
}
```

## Linting (optional)

It is recommended to use [state_beacon_lint](https://pub.dev/packages/state_beacon_lint) for package specific rules.

```bash
dart pub add custom_lint state_beacon_lint --dev
```

Enable the `custom_lint` plugin in your `analysis_options.yaml` file by adding the following.

```yaml
analyzer:
    plugins:
        - custom_lint
```

NB: Create the file if it doesn't exist.

## Features

-   [Beacon.writable](#beaconwritable): Mutable beacon that allows both reading and writing.
    -   [Beacon.scopedWritable](#beaconscopedwritable): Returns a `ReadableBeacon` and a function for setting its value.
-   [Beacon.readable](#beaconreadable): Immutable beacon that only emit values, ideal for readonly data.
-   [Beacon.effect](#beaconeffect): React to changes in beacon values.
-   [BeaconScheduler](#beaconscheduler): Configure the scheduler for all beacons.
-   [Beacon.derived](#beaconderived): Derive values from other beacons, keeping them reactively in sync.
-   [Beacon.future](#beaconfuture): Derive values from asynchronous operations, managing state during computation.
    -   [overrideWith](#futurebeaconoverridewith): Replace the callback.
-   [Beacon.stream](#beaconstream): Create derived beacons from Dart streams. values are wrapped in an `AsyncValue`.
-   [Beacon.streamRaw](#beaconstreamraw): Like `Beacon.stream`, but it doesn't wrap the value in an `AsyncValue`.
-   [Beacon.batch](#beacondobatchupdate): Combine multiple updates into a single notification.
-   [Beacon.debounced](#beacondebounced): Delay value updates until a specified time has elapsed, preventing rapid or unwanted updates.
-   [Beacon.throttled](#beaconthrottled): Limit the frequency of value updates, ideal for managing frequent events or user input.
-   [Beacon.filtered](#beaconfiltered): Update values based on filter criteria.
-   [Beacon.timestamped](#beacontimestamped): Attach timestamps to each value update.
-   [Beacon.undoRedo](#beaconundoredo): Provides the ability to undo and redo value changes.
-   [Beacon.bufferedCount](#beaconbufferedcount): Create a buffer/list of values based an `int` limit.
-   [Beacon.bufferedTime](#beaconbufferedtime): Create a buffer/list of values based on a time limit.
-   [Beacon.list](#beaconlist): Manage reactive lists that automatically update dependent beacons upon changes.
    -   [Beacon.hashSet](#beaconhashset): Like Beacon.list, but for Sets.
    -   [Beacon.hashMap](#beaconhashmap): Like Beacon.list, but for Maps.
-   [AsyncValue](#asyncvalue): A wrapper around a value that can be in one of four states: `idle`, `loading`, `data`, or `error`.
    -   [unwrap](#asyncvalueunwrap): Casts this [AsyncValue] to [AsyncData] and return its value.
    -   [lastData](#asyncvaluelastdata): Returns the latest valid data value or null.
    -   [tryCatch](#asyncvaluetrycatch): Execute a future and return [AsyncData] or [AsyncError].
    -   [optimistic updates](#asyncvaluetrycatch): Update the value optimistically when using tryCatch.
-   [Beacon.family](#beaconfamily): Create and manage a family of related beacons.
-   [Extension Methods](#extensions): Additional methods for beacons that can be chained.
    -   [stream](#mybeaconstream): Obtain a stream from a beacon, enabling integration with stream-based APIs and libraries.
    -   [wrap](#mywritablewrapanybeacon): Wraps an existing beacon and consumes its values
    -   [ingest](#mywritableingestanystream): Wraps any stream and consumes its values
    -   [next](#mybeaconnext): Allows awaiting the next value as a future.
    -   [Chaining Beacons](#chaining-methods): Seamlessly chain beacons to create sophisticated reactive pipelines, combining multiple functionalities for advanced value manipulation and control.
        -   [buffer](#mybeaconbuffer): Returns a [Beacon.bufferedCount](#beaconbufferedcount) that wraps this beacon.
        -   [bufferTime](#mybeaconbuffertime): Returns a [Beacon.bufferedTime](#beaconbufferedtime) that wraps this beacon.
        -   [throttle](#mybeaconthrottle): Returns a [Beacon.throttled](#beaconthrottled) that wraps this beacon.
        -   [filter](#mybeaconfilter): Returns a [Beacon.filtered](#beaconfiltered) that wraps this beacon.
        -   [debounce](#mybeacondebounce): Returns a [Beacon.debounced](#beacondebounced) that wraps this beacon.

[Pitfalls](#pitfalls)

### Beacon.writable:

Creates a `WritableBeacon` from a value that can be read and written to.

```dart
final counter = Beacon.writable(0);
counter.value = 10;
print(counter.value); // 10
```

### Beacon.lazyWritable:

Like `Beacon.writable` but behaves like a `late` variable. It must be set before it's read.

#### NB: All writable beacons have a lazy counterpart.

```dart
final counter = Beacon.lazyWritable();

print(counter.value); // throws UninitializeLazyReadException()

counter.value = 10;
print(counter.value); // 10
```

### Beacon.scopedWritable:

Returns a `ReadableBeacon` and a function for setting its value.
This is useful for creating a beacon that's readable by the public,
but writable only by the owner.

```dart
var (count,setCount) = Beacon.scopedWritable(15);
```

### Beacon.readable:

Creates an immutable `ReadableBeacon` from a value. This is useful for exposing a beacon's value to consumers without allowing them to modify it.

```dart
final counter = Beacon.readable(10);
counter.value = 10; // Compilation error


final _internalCounter = Beacon.writable(10);

// Expose the beacon's value without allowing it to be modified
ReadableBeacon<int> get counter => _internalCounter;
```

### Beacon.effect:

An effect is just a function that will re-run whenever one of its
dependencies change. An effect is scheduled to run immediately after creation.

```dart
final age = Beacon.writable(15);

Beacon.effect(() {
    if (age.value >= 18) {
      print("You can vote!");
    } else {
       print("You can't vote yet");
    }
 });

// Outputs: "You can't vote yet"

age.value = 20; // Outputs: "You can vote!"
```

### BeaconScheduler:

`Effects` are not synchronous, their execution is controlled by a scheduler. When a dependency of an `effect` changes, it is added to a queue and the scheduler decides when is the best time to flush the queue. By default, the queue is flushed with a DARTVM microtask which runs on the next loop; this can be changed by setting a custom scheduler.

A 60fps scheduler is included, this limits processing effects to 60 times per second. This can be done by calling `BeaconScheduler.use60FpsScheduler();` in the `main` function. You can also create your own custom scheduler for more advanced use cases. eg: `Gaming`: Synchronize flushing with your game loop.

When testing synchronous code, it is necessary to flush the queue manually. This can be done by calling `BeaconScheduler.flush();` in your test.

> [!NOTE]
> When writing widget tests, manual flushing isn't needed. The queue is automatically flushed when you call `tester.pumpAndSettle()`.

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

### Beacon.derived:

Creates a `DerivedBeacon` whose value is derived from a computation function.
This beacon will recompute its value every time one of it's dependencies change.

If `shouldSleep` is `true`(default), the callback will not execute if the beacon is no longer being watched.
It will resume executing once a listener is added or its value is accessed.

If `supportConditional` is `false`(default: true), it will only look dependencies on its first run.
This means once a beacon is added as a dependency, it will not be removed even if it's no longer used and no new dependencies will be added. This can be used a performance optimization.

Example:

```dart
final age = Beacon.writable<int>(18);
final canDrink = Beacon.derived(() => age.value >= 21);

print(canDrink.value); // Outputs: false

age.value = 22;

print(canDrink.value); // Outputs: true
```

### Beacon.future:

Creates a `FutureBeacon` whose value is derived from an asynchronous computation.
This beacon will recompute its value every time one of its dependencies change.
The result is wrapped in an `AsyncValue`, which can be in one of four states: `idle`, `loading`, `data`, or `error`.

If `manualStart` is `true` (default: false), the beacon will be in the `idle` state and the future will not execute until `start()` is called. Calling `start()` on a beacon that's already started will have no effect.

If `shouldSleep` is `true`(default), the callback will not execute if the beacon is no longer being watched.
It will resume executing once a listener is added or its value is accessed.
This means that it will enter the `loading` state when woken up.

> [!IMPORTANT]
> Only beacons accessed before the async gap will be tracked as dependencies. See [pitfalls](#pitfalls) for more details.

Example:

```dart
final counter = Beacon.writable(0);

// The future will be recomputed whenever the counter changes
final futureCounter = Beacon.future(() async {
  final count = counter.value;
  await Future.delayed(Duration(seconds: count));
  return '$count second has passed.';
});

class FutureCounter extends StatelessWidget {
const FutureCounter({super.key});

@override
Widget build(BuildContext context) {
  return switch (futureCounter.watch(context)) {
    AsyncData<String>(value: final v) => Text(v),
    AsyncError(error: final e) => Text('$e'),
    AsyncLoading() || AsyncIdle() => const CircularProgressIndicator(),
  };
}
}
```

Can be transformed into a future with `myFutureBeacon.toFuture()`
This can useful when a FutureBeacon depends on another FutureBeacon.
This functionality is also available to StreamBeacons.

```dart
var count = Beacon.writable(0);

var firstName = Beacon.future(() async {
  final val = count.value;
  await Future.delayed(k10ms);
  return 'Sally $val';
});

var lastName = Beacon.future(() async {
  final val = count.value + 1;
  await Future.delayed(k10ms);
  return 'Smith $val';
});

var fullName = Beacon.future(() async {
  // wait for the future to complete
  // we don't have to manually handle all the states
  final [fname, lname] = await Future.wait(
    [
      firstName.toFuture(),
      lastName.toFuture(),
    ],
  );

  return '$fname $lname';
});
```

#### FutureBeacon.overrideWith:

Replaces the current callback and resets the beacon by running the new callback.
This can also be done with [FutureBeacons](#beaconfuture).

```dart
var futureBeacon = Beacon.future(() async => 1);

await Future.delayed(k1ms);

expect(futureBeacon.value.unwrap(), 1);

futureBeacon.overrideWith(() async => throw Exception('error'));

await Future.delayed(k1ms);

expect(futureBeacon.value, isA<AsyncError>());
```

### Beacon.stream:

Creates a `StreamBeacon` from a given stream.
When a dependency changes, the beacon will unsubscribe from the old stream and subscribe to the new one.
This beacon updates its value based on the stream's emitted values.
The emitted values are wrapped in an `AsyncValue`, which can be in one of 4 states:`idle`, `loading`, `data`, or `error`.
This can we wrapped in a Throttled or Filtered beacon to control the rate of updates.
Can be transformed into a future with `mystreamBeacon.toFuture()`:

```dart
var myStream = Stream.periodic(Duration(seconds: 1), (i) => i);

var myBeacon = Beacon.stream(() => myStream);

myBeacon.subscribe((value) {
  print(value); // Outputs AsyncLoading(),AsyncData(0),AsyncData(1),AsyncData(2),...
});
```

### Beacon.streamRaw:

Like `Beacon.stream`, but it doesn't wrap the value in an `AsyncValue`.
When a dependency changes, the beacon will unsubscribe from the old stream and subscribe to the new one.

One of the following must be `true` if an initial value isn't provided:

1. The type is nullable
2. `isLazy` is true (beacon must be set before it's read from)

```dart
var myStream = Stream.periodic(Duration(seconds: 1), (i) => i);

var myBeacon = Beacon.streamRaw(() => myStream, initialValue: 0);

myBeacon.subscribe((value) {
  print(value); // Outputs 0,1,2,3,...
});
```

### Beacon.batch:

This allows multiple updates to be batched into a single update.
This can be used to optimize performance by reducing the number of update notifications.

```dart
final age = Beacon.writable<int>(10);

var callCount = 0;

age.subscribe((_) => callCount++);

Beacon.batch(() {
  age.value = 15;
  age.value = 16;
  age.value = 20;
  age.value = 23;
});

expect(callCount, equals(1)); // There were 4 updates, but only 1 notification
```

### Beacon.debounced:

Creates a `DebouncedBeacon` that will delay updates to its value based on the duration. This is useful when you want to wait until a user has stopped typing before performing an action.

```dart
var query = Beacon.debounced('', duration: Duration(seconds: 1));

query.subscribe((value) {
  print(value); // Outputs: 'apple' after 1 second
});

// simulate user typing
query.value = 'a';
query.value = 'ap';
query.value = 'app';
query.value = 'appl';
query.value = 'apple';

// after 1 second, the value will be updated to 'apple'
```

### Beacon.throttled:

Creates a `ThrottledBeacon` that will limit the rate of updates to its value based on the duration.

If `dropBlocked` is `true`(default), values will be dropped while the beacon is blocked, otherwise, values will be buffered and emitted one by one when the beacon is unblocked.

```dart
const k10ms = Duration(milliseconds: 10);
var beacon = Beacon.throttled(10, duration: k10ms);

beacon.set(20);
expect(beacon.value, equals(20)); // first update allowed

beacon.set(30);
expect(beacon.value, equals(20)); // too fast, update ignored

await Future.delayed(k10ms * 1.1);

beacon.set(30);
expect(beacon.value, equals(30)); // throttle time passed, update allowed
```

### Beacon.filtered:

Creates a `FilteredBeacon` that will only updates its value if it passes the filter criteria.
The filter function receives the previous and new values as arguments.
The filter function can also be changed using the `setFilter` method.

#### Simple Example:

```dart
// only positive values are allowed
var pageNum = Beacon.filtered(10, filter: (prev, next) => next > 0);
pageNum.value = 20; // update is allowed
pageNum.value = -5; // update is ignored
```

#### Example when filter function depends on another beacon:

In this example, `posts` is a derived future beacon that will fetch the posts whenever `pageNum` changes.
We want to prevent the user from changing `pageNum` while `posts` is loading.

```dart
var pageNum = Beacon.filtered(1); // we will set the filter function later

final posts = Beacon.future(() => Repository.getPosts(pageNum.value));

// can't change pageNum while loading
pageNum.setFilter((prev, next) => !posts.isLoading);
```

Extracted from the [infinite list example](https://github.com/jinyus/dart_beacon/tree/main/examples/flutter_main/lib/infinite_list)

### Beacon.timestamped:

Creates a `TimestampBeacon` that attaches a timestamp to each value update.

```dart
var myBeacon = Beacon.timestamped(10);
print(myBeacon.value); // Outputs: (value: 10, timestamp: __CURRENT_TIME__)
```

### Beacon.undoRedo:

Creates an `UndoRedoBeacon` that allows undoing and redoing changes to its value.

```dart
var age = Beacon.undoRedo(0, historyLimit: 10);

age.value = 10;
age.value = 20;

age.undo(); // Reverts to 10
age.redo(); // Goes back to 20
```

### Beacon.bufferedCount:

Creates a `BufferedCountBeacon` that collects and buffers a specified number
of values. Once the count threshold is reached, the beacon's value is updated
with the list of collected values and the buffer is reset.

This beacon is useful in scenarios where you need to aggregate a certain
number of values before processing them together.

```dart
var countBeacon = Beacon.bufferedCount<int>(3);

countBeacon.subscribe((values) {
  print(values);
});

countBeacon.add(1);
countBeacon.add(2);
countBeacon.add(3); // Triggers update and prints [1, 2, 3]
```

You may also access the `currentBuffer` as a readable beacon.
See it in use in the [konami example](https://github.com/jinyus/dart_beacon/tree/main/examples/flutter_main/lib/konami);

### Beacon.bufferedTime:

Creates a `BufferedTimeBeacon` that collects values over a specified time duration.
Once the time duration elapses, the beacon's value is updated with the list of
collected values and the buffer is reset.

```dart
var timeBeacon = Beacon.bufferedTime<int>(duration: Duration(seconds: 5));

timeBeacon.subscribe((values) {
  print(values);
});

timeBeacon.add(1);
timeBeacon.add(2);
// After 5 seconds, it will output [1, 2]
```

### Beacon.list:

The `ListBeacon` provides methods to add, remove, and update items in the list and notifies listeners without having to make a copy.

_NB_: The `previousValue` and current value will always be the same because the same list is being mutated. If you need access to the previousValue, use Beacon.writable<List>([]) instead.

#### Beacon.hashSet:

Similar to Beacon.list(), but for Sets.

#### Beacon.hashMap:

Similar to Beacon.list(), but for Maps.

```dart
var nums = Beacon.list<int>([1, 2, 3]);

Beacon.effect(() {
 print(nums.value); // Outputs: [1, 2, 3]
});

nums.add(4); // Outputs: [1, 2, 3, 4]

nums.remove(2); // Outputs: [1, 3, 4]
```

### AsyncValue:

An `AsyncValue` is a wrapper around a value that can be in one of four states:`idle`, `loading`, `data`, or `error`.
This is the value type of [FutureBeacons](#beaconfuture),[FutureBeacons](#beaconfuture) and [StreamBeacons](#beaconstream).

```dart
var myBeacon = Beacon.future(() async {
  return await Future.delayed(Duration(seconds: 1), () => 'Hello');
});

print(myBeacon.value); // Outputs AsyncLoading immediately

await Future.delayed(Duration(seconds: 1));

print(myBeacon.value); // Outputs AsyncData('Hello')
```

#### AsyncValue.unwrap():

Casts this [AsyncValue] to [AsyncData] and return its value. This will throw an error if the value is not an [AsyncData].

```dart
var name = AsyncData('Bob');
print(name.unwrap()); // Outputs: Bob

name = AsyncLoading();
print(name.unwrap()); // Throws error
```

#### AsyncValue.lastData:

Returns the latest valid data value or null. This is useful when you want to display the last valid value while loading new data.

```dart
var myBeacon = Beacon.future(() async {
  return await Future.delayed(Duration(seconds: 1), () => 'Hello');
});

print(myBeacon.value); // Outputs AsyncLoading immediately

print(myBeacon.value.lastData); // Outputs null as there is no valid data yet

await Future.delayed(Duration(seconds: 1));

print(myBeacon.value.lastData); // Outputs 'Hello'

myBeacon.reset();

print(myBeacon.value); // Outputs AsyncLoading

print(myBeacon.value.lastData); // Outputs 'Hello' as the last valid data when in loading state
```

#### AsyncValue.tryCatch:

Executes the future provided and returns [AsyncData] with the result
if successful or [AsyncError] if an exception is thrown.

Supply an optional [WritableBeacon] that will be set throughout the
various states.

Supply an optional [optimisticResult] that will be set while loading, instead of [AsyncLoading].

```dart
Future<String> fetchUserData() {
  // Imagine this is a network request that might throw an error
  return Future.delayed(Duration(seconds: 1), () => 'User data');
}
  beacon.value = AsyncLoading();
  beacon.value = await AsyncValue.tryCatch(fetchUserData);
```

You can also pass the beacon as a parameter.
`loading`,`data` and `error` states,
as well as the last successful data will be set automatically.

```dart
await AsyncValue.tryCatch(fetchUserData, beacon: beacon);

// or use the extension method.

await beacon.tryCatch(fetchUserData);
```

See it in use in the [shopping cat example](https://github.com/jinyus/dart_beacon/tree/main/examples/shopping_cart/lib/src/cart).

If you want to do optimistic updates, you can supply an optional `optimisticResult` parameter.

```dart
await beacon.tryCatch(mutateUserData, optimisticResult: 'User data');
```

Without `tryCatch`, handling the potential error requires more
boilerplate code:

```dart
  beacon.value = AsyncLoading();
  try {
    beacon.value = AsyncData(await fetchUserData());
  } catch (err,stacktrace) {
    beacon.value = AsyncError(err, stacktrace);
  }
```

### Beacon.family:

Creates and manages a family of related `Beacon`s based on a single creation function.

This class provides a convenient way to handle related
beacons that share the same creation logic but have different arguments.

### Type Parameters:

-   `T`: The type of the value emitted by the beacons in the family.
-   `Arg`: The type of the argument used to identify individual beacons within the family.
-   `BeaconType`: The type of the beacon in the family.

If `cache` is `true`, created beacons are cached. Default is `false`.

Example:

```dart
final apiClientFamily = Beacon.family(
 (String baseUrl) {
   return Beacon.readable(ApiClient(baseUrl));
 },
);

final githubApiClient = apiClientFamily('https://api.github.com');
final twitterApiClient = apiClientFamily('https://api.twitter.com');
```

## Extensions:

### myBeacon.stream:

This returns a stream that emits the beacon's value whenever it changes.

### myWritable.wrap(anyBeacon):

Wraps an existing beacon and consumes its values

Supply a (`then`) function to customize how the emitted values are
processed.

```dart
var bufferBeacon = Beacon.bufferedCount<String>(10);
var count = Beacon.writable(5);

// Wrap the bufferBeacon with the readableBeacon and provide a custom transformation.
bufferBeacon.wrap(count, then: (value) {
  // Custom transformation: Convert the value to a string and add it to the buffer.
  bufferBeacon.add(value.toString());
});

print(bufferBeacon.buffer); // Outputs: ['5']
count.value = 10;
print(bufferBeacon.buffer); // Outputs: ['5', '10']
```

This method is available on all writable beacons, including BufferedBeacons; and can wrap any beacon since all beacons are readable.

### myWritable.ingest(anyStream):

This functions like `.wrap()` but it's specifically for streams. It listens to the stream and updates the beacon's value with the emitted values.

```dart
final beacon = Beacon.writable(0);
final myStream = Stream.fromIterable([1, 2, 3]);

beacon.ingest(myStream);

beacon.subscribe((value) {
  print(value); // Outputs: 1, 2, 3
});
```

### mybeacon.next():

Listens for the next value emitted by this Beacon and returns it as a Future.

This method subscribes to this Beacon and waits for the next value
that matches the optional [filter] function. If [filter] is provided and
returns `false` for a emitted value, the method continues waiting for the
next value that matches the filter. If no [filter] is provided,
the method completes with the first value received.

If a value is not emitted within the specified [timeout] duration (default
is 10 seconds), the method times out and returns the current value of the beacon.

```dart
final age = Beacon.writable(20);

Timer(Duration(seconds: 1), () => age.value = 21;);

final nextAge = await age.next(); // returns 21 after 1 second
```

## Chaining methods:

Seamlessly chain beacons to create sophisticated reactive pipelines, combining multiple functionalities for advanced value manipulation and control.

```dart
// every write to this beacon will be filtered then debounced.
final searchQuery = Beacon.writable('').filter(filter: (prev, next) => next.length > 2).debounce(duration: k500ms);
```

> [!IMPORTANT]  
> When chaining beacons, all writes made to the returned beacon will be re-routed to the first beacon in the chain.

```dart
const k500ms = Duration(milliseconds: 500);

final count = Beacon.writable(10);

final filteredCount = count
        .debounce(duration: k500ms),
        .filter(filter: (prev, next) => next > 10);

filteredCount.value = 20;
// The mutation will be re-routed to count
// before being passed to the debounced beacon
// then to the filtered beacon.
// This is equivalent to count.value = 20;

expect(count.value, equals(20));

await Future.delayed(k500ms);

expect(filteredCount.value, equals(20));
```

> [!WARNING]  
> `buffer` and `bufferTime` cannot be mid-chain. If they are used, they have to be the last in the chain.

```dart
// GOOD
someBeacon.filter().buffer(10);

// BAD
someBeacon.buffer(10).filter();
```

### mybeacon.buffer():

Returns a [Beacon.bufferedCount](#beaconbufferedcount) that wraps this beacon.

NB: The returned beacon will be disposed when the wrapped beacon is disposed.

```dart
final age = Beacon.writable(20);

final bufferedAge = age.buffer(10);

bufferedAge.subscribe((value) {
  print(value); // Outputs: [20, 21, 22, 23, 24, 25, 26, 27, 28, 29]
});

for (var i = 0; i < 10; i++) {
  age.value++;
}
```

### mybeacon.bufferTime():

Returns a [Beacon.bufferedTime](#beaconbufferedtime) that wraps this beacon.

### mybeacon.throttle():

Returns a [Beacon.throttled](#beaconthrottled) that wraps this beacon.

### mybeacon.filter():

Returns a [Beacon.filtered](#beaconfiltered) that wraps this beacon.

### mybeacon.map():

Returns a [ReadableBeacon] that wraps a Beacon and tranforms its values.

```dart
final stream = Stream.periodic(k1ms, (i) => i).take(5);
final beacon = stream
    .toRawBeacon(isLazy: true)
    .map((v) => v + 1)
    .filter(filter: (_, n) => n.isEven);

await expectLater(beacon.stream, emitsInOrder([1, 2, 4]));
```

> [!NOTE]
> When `map` returns a different type, writes to the returned beacon will not be re-routed to the original beacon. In the example below, writes to `filteredBeacon` will NOT be re-routed to `count` because `map` returns a `String` and `count` holds an `int`.

```dart
final count = Beacon.writable(0);
final filteredBeacon = count.map((v) => '$v').filter(filter: (_, n) => n.length > 1);
```

### mybeacon.debounce():

Returns a [Beacon.debounced](#beacondebounced) that wraps this beacon.

```dart
final query = Beacon.writable('');

const k500ms = Duration(milliseconds: 500);

final debouncedQuery = query
        .filter(filter: (prev, next) => next.length > 2)
        .debounce(duration: k500ms);
```

## Pitfalls

When using `Beacon.future`, only beacons accessed before the async gap(`await`) will be tracked as dependencies.

```dart
final counter = Beacon.writable(0);
final doubledCounter = Beacon.derived(() => counter.value * 2);

final futureCounter = Beacon.future(() async {
  // This will be tracked as a dependency because it's accessed before the async gap
  final count = counter.value;

  await Future.delayed(Duration(seconds: count));

  // This will NOT be tracked as a dependency because it's accessed after `await`
  final doubled = doubledCounter.value;

  return '$count x 2 =  $doubled';
});
```

When a future depends on multiple future/stream beacons

-   DON'T:

```dart
final futureCounter = Beacon.future(() async {
  // in this instance lastNameStreamBeacon will not be tracked as a dependency
  // because it's accessed after the async gap
  final firstName = await firstNameFutureBeacon.toFuture();
  final lastName = await lastNameStreamBeacon.toFuture();

  return 'Fullname is $firstName $lastName';
});
```

-   DO:

```dart
final futureCounter = Beacon.future(() async {
  // store the futures before the async gap ie: don't use await
  final firstNameFuture = firstNameFutureBeacon.toFuture();
  final lastNameFuture = lastNameStreamBeacon.toFuture();

  // wait for the futures to complete
  final (String firstName, String lastName) = await (firstNameFuture, lastNameFuture).wait;

  return 'Fullname is $firstName $lastName';
});
```
