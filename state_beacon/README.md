<p align="center">
  <img width="200" src="https://github.com/jinyus/dart_beacon/blob/main/assets/logo.png?raw=true">
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
final derivedFutureCounter = Beacon.derivedFuture(() async {
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
    return switch (derivedFutureCounter.watch(context)) {
      AsyncData<String>(value: final v) => Text(v),
      AsyncError(error: final e) => Text('$e'),
      _ => const CircularProgressIndicator(),
    };
  }
}
```

## Features

-   [Beacon.writable](#beaconwritable): Read and write values.
    -   [Beacon.scopedWritable](#beaconscopedwritable): Returns a `ReadableBeacon` and a function for setting its value.
-   [Beacon.readable](#beaconreadable): Read-only values.
-   [Beacon.createEffect](#beaconcreateeffect): React to changes in beacon values.
-   [Beacon.doBatchUpdate](#beacondobatchupdate): Batch multiple updates into a single notification.
-   [Beacon.debounced](#beacondebounced): Debounce value changes over a specified duration.
-   [Beacon.throttled](#beaconthrottled): Throttle value changes based on a duration.
-   [Beacon.filtered](#beaconfiltered): Update values based on filter criteria.
-   [Beacon.timestamped](#beacontimestamped): Attach timestamps to each value update.
-   [Beacon.undoRedo](#beaconundoredo): Undo and redo value changes.
-   [Beacon.bufferedCount](#beaconbufferedcount): Create a buffer/list of values based a int limit.
-   [Beacon.bufferedTime](#beaconbufferedtime): Create a buffer/list of values based on a time limit.
-   [Beacon.stream](#beaconstream): Create beacons from Dart streams.
-   [Beacon.streamRaw](#beaconstreamraw): Create beacons from Dart streams.
-   [Beacon.future](#beaconfuture): Initialize beacons from futures.
    -   [overrideWith](#futurebeaconoverridewith): Replace the callback.
-   [Beacon.derived](#beaconderived): Compute values reactively based on other beacons.
-   [Beacon.derivedFuture](#beaconderivedfuture): Asynchronously compute values with state tracking.
-   [Beacon.list](#beaconlist): Manage lists reactively.
    -   [Beacon.hashSet](#beaconhashset): Manage Sets reactively.
    -   [Beacon.hashMap](#beaconhashmap): Manage Maps reactively.
-   [AsyncValue](#asyncvalue): A wrapper around a value that can be in one of four states: `idle`, `loading`, `data`, or `error`.
    -   [unwrap](#asyncvalueunwrap): Casts this [AsyncValue] to [AsyncData] and return it's value.
    -   [lastData](#asyncvaluelastdata): Returns the latest valid data value or null.
-   [Beacon.family](#beaconfamily): Create and manage a family of related beacons.

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

### Beacon.scopedWritable:

Returns a `ReadableBeacon` and a function for setting its value.
This is useful for creating a beacon that's readable by the public,
but writable only by the owner.

```dart
var (count,setCount) = Beacon.scopedWritable(15);
```

#### NB: All writable beacons have a lazy counterpart.

```dart
final counter = Beacon.lazyWritable();
print(counter.value); // throws UninitializeLazyReadException()

counter.value = 10;
print(counter.value); // 10
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

### Beacon.createEffect:

An effect is just a function that will re-run whenever one of its
dependencies change. An effect runs immediately after creation.

```dart
final age = Beacon.writable(15);

Beacon.createEffect(() {
    if (age.value >= 18) {
      print("You can vote!");
    } else {
       print("You can't vote yet");
    }
 });

// Outputs: "You can't vote yet"

age.value = 20; // Outputs: "You can vote!"
```

### Beacon.doBatchUpdate:

Executes a batched update which allows multiple updates to be batched into a single update.
This can be used to optimize performance by reducing the number of update notifications.

```dart
final age = Beacon.writable<int>(10);

var callCount = 0;

age.subscribe((_) => callCount++);

Beacon.doBatchUpdate(() {
  age.value = 15;
  age.value = 16;
  age.value = 20;
  age.value = 23;
});

expect(callCount, equals(1)); // There were 4 updates, but only 1 notification
```

### Beacon.derived:

Creates a `DerivedBeacon` whose value is derived from a computation function.
This beacon will recompute its value everytime one of it's dependencies change.

Example:

```dart
final age = Beacon.writable<int>(18);
final canDrink = Beacon.derived(() => age.value >= 21);

print(canDrink.value); // Outputs: false

age.value = 22;

print(canDrink.value); // Outputs: true
```

### Beacon.derivedFuture:

Creates a `DerivedBeacon` whose value is derived from an asynchronous computation.
This beacon will recompute its value every time one of its dependencies change.
The result is wrapped in an `AsyncValue`, which can be in one of four states: `idle`, `loading`, `data`, or `error`.

If `manualStart` is `true` (default: false), the beacon will be in the `idle` state and the future will not execute until [start()] is called.

If `cancelRunning` is `true` (default: true), the results of a current execution will be discarded
if another execution is triggered before the current one finishes.

Example:

```dart
final counter = Beacon.writable(0);

// The future will be recomputed whenever the counter changes
final derivedFutureCounter = Beacon.derivedFuture(() async {
  final count = counter.value;
  await Future.delayed(Duration(seconds: count));
  return '$count second has passed.';
});

class FutureCounter extends StatelessWidget {
const FutureCounter({super.key});

@override
Widget build(BuildContext context) {
  return switch (derivedFutureCounter.watch(context)) {
    AsyncData<String>(value: final v) => Text(v),
    AsyncError(error: final e) => Text('$e'),
    AsyncLoading() || AsyncIdle() => const CircularProgressIndicator(),
  };
}
}
```

Can be transformed into a future with `myFutureBeacon.toFuture()`
This can useful when a DerivedFutureBeacon depends on another DerivedFutureBeacon.
This functionality is also availabe to regular FutureBeacons and StreamBeacons.

```dart
var count = Beacon.writable(0);

var firstName = Beacon.derivedFuture(() async {
  final val = count.value;
  await Future.delayed(k10ms);
  return 'Sally $val';
});

var lastName = Beacon.derivedFuture(() async {
  final val = count.value + 1;
  await Future.delayed(k10ms);
  return 'Smith $val';
});

var fullName = Beacon.derivedFuture(() async {
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

### Beacon.debounced:

Creates a `DebouncedBeacon` with an initial value and a debounce duration.
This beacon delays updates to its value based on the duration.

```dart
var myBeacon = Beacon.debounced(10, duration: Duration(seconds: 1));
myBeacon.value = 20; // Update is debounced
print(myBeacon.value); // Outputs: 10
await Future.delayed(Duration(seconds: 1));
print(myBeacon.value); // Outputs: 20
```

### Beacon.throttled:

Creates a `ThrottledBeacon` with an initial value and a throttle duration.
This beacon limits the rate of updates to its value based on the duration.
Updates that occur faster than the throttle duration are ignored.

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

Creates a `FilteredBeacon` with an initial value and a filter function.
This beacon updates its value only if it passes the filter criteria.
The filter function receives the previous and new values as arguments.
The filter function can also be changed using the `setFilter` method.

#### Simple Example:

```dart
var pageNum = Beacon.filtered(10, (prev, next) => next > 0); // only positive values are allowed
pageNum.value = 20; // update is allowed
pageNum.value = -5; // update is ignored
```

#### Example when filter function depends on another beacon:

```dart
var pageNum = Beacon.filtered(1); // we will set the filter function later

final posts = Beacon.derivedFuture(() async {Repository.getPosts(pageNum.value);});

pageNum.setFilter((prev, next) => posts.value is! AsyncLoading); // can't change pageNum while loading
```

### Beacon.timestamped:

Creates a `TimestampBeacon` with an initial value.
This beacon attaches a timestamp to each value update.

```dart
var myBeacon = Beacon.timestamped(10);
print(myBeacon.value); // Outputs: (value: 10, timestamp: __CURRENT_TIME__)
```

### Beacon.undoRedo:

Creates an `UndoRedoBeacon` with an initial value and an optional history limit.
This beacon allows undoing and redoing changes to its value.

```dart
var undoRedoBeacon = UndoRedoBeacon<int>(0, historyLimit: 10);
undoRedoBeacon.value = 10;
undoRedoBeacon.value = 20;
undoRedoBeacon.undo(); // Reverts to 10
undoRedoBeacon.redo(); // Goes back to 20
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

countBeacon.value = 1;
countBeacon.value = 2;
countBeacon.value = 3; // Triggers update and prints [1, 2, 3]
```

### Beacon.bufferedTime:

Creates a `BufferedTimeBeacon` that collects values over a specified time duration.
Once the time duration elapses, the beacon's value is updated with the list of
collected values and the buffer is reset.

```dart
var timeBeacon = Beacon.bufferedTime<int>(duration: Duration(seconds: 5));

timeBeacon.subscribe((values) {
  print(values);
});

timeBeacon.value = 1;
timeBeacon.value = 2;
// After 5 seconds, it will output [1, 2]
```

### Beacon.stream:

Creates a `StreamBeacon` from a given stream.
This beacon updates its value based on the stream's emitted values.
The emitted values are wrapped in an `AsyncValue`, which can be in one of three states: `loading`, `data`, or `error`.
This can we wrapped in a Throttled or Filtered beacon to control the rate of updates.
Can be transformed into a future with `mystreamBeacon.toFuture()`:

```dart
var myStream = Stream.periodic(Duration(seconds: 1), (i) => i);

var myBeacon = Beacon.stream(myStream);

myBeacon.subscribe((value) {
  print(value); // Outputs AsyncLoading(),AsyncData(0),AsyncData(1),AsyncData(2),...
});
```

### Beacon.streamRaw:

Like `Beacon.stream`, but it doesn't wrap the value in an `AsyncValue`.
If you don't supply an initial value, the type has to be nullable.

```dart
var myStream = Stream.periodic(Duration(seconds: 1), (i) => i);

var myBeacon = Beacon.streamRaw(myStream,initialValue: 0);

myBeacon.subscribe((value) {
  print(value); // Outputs 0,1,2,3,...
});
```

### Beacon.future:

Creates a `FutureBeacon` that initializes its value based on a future.
This can be refreshed by calling the `reset` method.

If `manualStart` is `true`, the future will not execute until [start()] is called.

```dart
var myBeacon = Beacon.future(() async {
  return await Future.delayed(Duration(seconds: 1), () => 'Hello');
});

myBeacon.subscribe((value) {
  print(value); // Outputs AsyncLoading immediately then AsyncData('Hello') after 1 second
});
```

#### FutureBeacon.overrideWith:

Replaces the current callback and resets the beacon by running the new callback.
This can also be done with [DerivedFutureBeacons](#beaconderivedfuture).

```dart
var futureBeacon = Beacon.future(() async => 1);

await Future.delayed(k1ms);

expect(futureBeacon.value.unwrap(), 1);

futureBeacon.overrideWith(() async => throw Exception('error'));

await Future.delayed(k1ms);

expect(futureBeacon.value, isA<AsyncError>());
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

Beacon.createEffect(() {
 print(nums.value); // Outputs: [1, 2, 3]
});

nums.add(4); // Outputs: [1, 2, 3, 4]

nums.remove(2); // Outputs: [1, 3, 4]
```

### myWritable.wrap(anyBeacon):

Wraps an existing beacon and comsumes its values

Supply a (`then`) function to customize how the emitted values are
processed.

```dart
var bufferBeacon = Beacon.bufferedCount<int>(10);
var count = Beacon.writable(5);

// Wrap the count beacon and provide a custom transformation.
bufferBeacon.wrap(
  count,
  then: (thisBeacon, countValue) {

      // Custom transformation: Add the value twice to the buffer.
      thisBeacon.add(countValue);
      thisBeacon.add(countValue);

});

print(bufferBeacon.buffer); // Outputs: [5, 5]

count.value = 10;

print(bufferBeacon.buffer); // Outputs: [5, 5, 10, 10]
```

### AsyncValue:

An `AsyncValue` is a wrapper around a value that can be in one of four states:`idle`, `loading`, `data`, or `error`.
This is the value type of [FutureBeacons](#beaconfuture),[DerivedFutureBeacons](#beaconderivedfuture) and [StreamBeacons](#beaconstream).

```dart
var myBeacon = Beacon.future(() async {
  return await Future.delayed(Duration(seconds: 1), () => 'Hello');
});

print(myBeacon.value); // Outputs AsyncLoading immediately

await Future.delayed(Duration(seconds: 1));

print(myBeacon.value); // Outputs AsyncData('Hello')
```

#### AsyncValue.unwrap():

Casts this [AsyncValue] to [AsyncData] and return it's value. This will throw an error if the value is not an [AsyncData].

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

## Pitfalls

When using `Beacon.derivedFuture`, only beacons accessed before the async gap(`await`) will be tracked as dependencies.

```dart
final counter = Beacon.writable(0);
final doubledCounter = Beacon.derived(() => counter.value * 2);

final derivedFutureCounter = Beacon.derivedFuture(() async {
  // This will be tracked as a dependency because it's accessed before the async gap
  final count = counter.value;

  await Future.delayed(Duration(seconds: count));

  // This will NOT be tracked as a dependency because it's accessed after `await`
  final doubled = doubledCounter.value;

  return '$count x 2 =  $doubled';
});
```

When a derivedFuture depends on multiple future/stream beacons

-   DONT:

```dart
final derivedFutureCounter = Beacon.derivedFuture(() async {
  // in this instance lastNameStreamBeacon will not be tracked as a dependency
  // because it's accessed after the async gap
  final firstName = await firstNameFutureBeacon.toFuture();
  final lastName = await lastNameStreamBeacon.toFuture();

  return 'Fullname is $firstName $lastName';
});
```

-   DO:

```dart
final derivedFutureCounter = Beacon.derivedFuture(() async {
  // acquire the futures before the async gap ie: don't use await
  final firstNameFuture = firstNameFutureBeacon.toFuture();
  final lastNameFuture = lastNameStreamBeacon.toFuture();

  // wait for the futures to complete
  final (String firstName, String lastName) = await (firstNameFuture, lastNameFuture).wait;

  return 'Fullname is $firstName $lastName';
});
```
