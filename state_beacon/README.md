<p align="center">
  <img width="200" src="https://github.com/jinyus/dart_beacon/blob/main/assets/logo.png?raw=true">
</p>

## Overview

A Beacon is a reactive primitive(`signal`) and simple state management solution for Dart and Flutter.

### Usage

Flutter web demo: https://flutter-beacon.surge.sh/
<br>All examples: https://github.com/jinyus/dart_beacon/examples

<p align="center">
  <picture>
    <source srcset="https://github.com/jinyus/dart_beacon/blob/main/assets/flutter-beacon-demo.webp?raw=true" type="image/webp">
    <img width="200" src="https://github.com/jinyus/dart_beacon/blob/main/assets/flutter-beacon-demo.gif?raw=true" alt="demo">
  </picture>
</p>

Click [here](https://github.com/jinyus/flutter_state_beacon/blob/main/flutter_beacon/example/lib/main.dart) for the full code.

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

-   **WritableBeacon**: Read and write values.
-   **ReadableBeacon**: Read-only values.
-   **DebouncedBeacon**: Debounce value changes over a specified duration.
-   **ThrottledBeacon**: Throttle value changes based on a duration.
-   **FilteredBeacon**: Update values based on filter criteria.
-   **TimestampBeacon**: Attach timestamps to each value update.
-   **UndoRedoBeacon**: Undo and redo value changes.
-   **BufferedBeacon**: Create a buffer/list of values.
-   **StreamBeacon**: Create beacons from Dart streams.
-   **FutureBeacon**: Initialize beacons from futures.
-   **DerivedBeacon**: Compute values reactively based on other beacons.
-   **DerivedFutureBeacon**: Asynchronously compute values with state tracking.
-   **ListBeacon**: Manage lists reactively.
-   **createEffect**: React to changes in beacon values.
-   **doBatchUpdate**: Batch multiple updates into a single notification.
