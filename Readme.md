<p align="center">
  <img width="200" src="https://github.com/jinyus/dart_beacon/blob/main/assets/logo.png?raw=true">
</p>

## Overview

A Beacon is a reactive primitive(`signal`) and simple state management solution for Dart and Flutter.

Flutter web demo([source](https://github.com/jinyus/dart_beacon/tree/main/examples/flutter_main/lib)): https://flutter-beacon.surge.sh/
<br>All examples: https://github.com/jinyus/dart_beacon/examples

<p align="center">
  <picture>
    <source srcset="https://github.com/jinyus/dart_beacon/blob/main/assets/flutter-beacon-demo.webp?raw=true" type="image/webp">
    <img width="200" src="https://github.com/jinyus/dart_beacon/blob/main/assets/flutter-beacon-demo.gif?raw=true" alt="demo">
  </picture>
</p>

## Installation

```bash
dart pub add state_beacon
```

## Usage

```dart
import 'package:state_beacon/state_beacon.dart';
```

#### Create a beacon

```dart
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

final counter = Beacon.writable(0);

// The future will be recomputed whenever the counter changes
final derivedFutureCounter = Beacon.derivedFuture(() async {
  final count = counter.value;
  return await counterFuture(count);
});

Future<String> counterFuture(int count) async {
  await Future.delayed(Duration(seconds: count));
  return '$count second has passed.';
}
```

#### Watch it in a widget

```dart
class Counter extends StatelessWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      counter.watch(context).toString(),
      style: Theme.of(context).textTheme.headlineMedium!,
    );
  }
}

class FutureCounter extends StatelessWidget {
  const FutureCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (derivedFutureCounter.watch(context)) {
      AsyncData<String>(value: final v) => Text(v),
      AsyncError(error: final e) => Text('$e'),
      AsyncLoading() => const CircularProgressIndicator(),
    };
  }
}
```

## Features

-   [Beacon.writable](https://github.com/jinyus/dart_beacon#beaconwritable): Read and write values.
-   [Beacon.readable](https://github.com/jinyus/dart_beacon#beaconreadable): Read-only values.
-   [Beacon.debounced](https://github.com/jinyus/dart_beacon#beacondebounced): Debounce value changes over a specified duration.
-   [Beacon.throttled](https://github.com/jinyus/dart_beacon#beaconthrottled): Throttle value changes based on a duration.
-   [Beacon.filtered](https://github.com/jinyus/dart_beacon#beaconfiltered): Update values based on filter criteria.
-   [Beacon.timestamped](https://github.com/jinyus/dart_beacon#beacontimestamped): Attach timestamps to each value update.
-   [Beacon.undoRedo](https://github.com/jinyus/dart_beacon#beaconundoredo): Undo and redo value changes.
-   [Beacon.bufferedCount](https://github.com/jinyus/dart_beacon#beaconbufferedcount): Create a buffer/list of values based a int limit.
-   [Beacon.bufferedTime](https://github.com/jinyus/dart_beacon#beaconbufferedtime): Create a buffer/list of values based on a time limit.
-   [Beacon.stream](https://github.com/jinyus/dart_beacon#beaconstream): Create beacons from Dart streams.
-   [Beacon.future](https://github.com/jinyus/dart_beacon#beaconfuture): Initialize beacons from futures.
-   [Beacon.derived](https://github.com/jinyus/dart_beacon#beaconderived): Compute values reactively based on other beacons.
-   [Beacon.derivedFuture](https://github.com/jinyus/dart_beacon#beaconderivedfuture): Asynchronously compute values with state tracking.
-   [Beacon.list](https://github.com/jinyus/dart_beacon#beaconlist): Manage lists reactively.
-   [Beacon.createEffect](https://github.com/jinyus/dart_beacon#beaconcreateeffect): React to changes in beacon values.
-   [Beacon.doBatchUpdate](https://github.com/jinyus/dart_beacon#beacondobatchupdate): Batch multiple updates into a single notification.

### Beacon.writable:

```dart
final counter = Beacon.writable(0);
counter.value = 10;
print(counter.value); // 10
```

### Beacon.lazyWritable:

Like `Beacon.writable` but behaves like a `late` variable. It must be set before it's read.

```dart
final counter = Beacon.lazyWritable();
print(counter.value); // throws UninitializeLazyReadException()

counter.value = 10;
print(counter.value); // 10
```

### Beacon.readable:

```dart
final counter = Beacon.readable(10);
counter.value = 10; // Compilation error
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
The result is wrapped in an `AsyncValue`, which can be in one of three states: loading, data, or error.

If `manualStart` is `true` (default: false), the future will not execute until [start()] is called.

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
    AsyncLoading() => const CircularProgressIndicator(),
  };
}
}
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

### Beacon.filterd:

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
This can we wrapped in a Throttled or Filtered beacon to control the rate of updates.

```dart
var myStream = Stream.periodic(Duration(seconds: 1), (i) => i);

var myBeacon = Beacon.stream(myStream);

myBeacon.subscribe((value) {
  print(value); // Outputs the stream's emitted values
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
  print(value); // Outputs 'Hello' after 1 second
});
```

### Beacon.list:

Creates a `ListBeacon` with an initial list value.
This beacon manages a list of items, allowing for reactive updates and manipulations of the list.

```dart
var nums = Beacon.list<int>([1, 2, 3]);

Beacon.createEffect(() {
 print(nums.value); // Outputs: [1, 2, 3]
});

nums.add(4); // Outputs: [1, 2, 3, 4]

nums.remove(2); // Outputs: [1, 3, 4]
```

### Beacon.createEffect:

Creates an effect based on a provided function. The provided function will be called
whenever one of its dependencies change.

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

### myWritable.wrap(anyBeacon):

Wraps an existing beacon and comsumes its values

Supply a (`then`) function to customize how the emitted values are
processed.

```dart
var bufferBeacon = Beacon.bufferedCount<int>(10);
var count = Beacon.writable(5);

// Wrap the count beacon and provide a custom transformation.
bufferBeacon.wrap(count, then: (beacon, value) {
  // Custom transformation: Add the value twice to the buffer.
  beacon.add(value);
  beacon.add(value);
});

print(bufferBeacon.buffer); // Outputs: [5, 5]

count.value = 10;

print(bufferBeacon.buffer); // Outputs: [5, 5, 10, 10]
```
