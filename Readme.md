<p align="center">
  <img width="200" src="https://github.com/jinyus/dart_beacon/blob/master/logo.png?raw=true">
</p>

## Overview

A Beacon is a powerful reactive primitive for dart. It provides facilities for executing any code when a value is updated.

## Features

-   **WritableBeacon**: Read and write values reactively.
-   **ReadableBeacon**: Read-only reactive values.
-   **LazyBeacon**: Lazy initialization of reactive values.
-   **DebouncedBeacon**: Debounce value changes over a specified duration.
-   **ThrottledBeacon**: Throttle value changes based on a duration.
-   **FilteredBeacon**: Update values based on filter criteria.
-   **TimestampBeacon**: Attach timestamps to each value update.
-   **StreamBeacon**: Create beacons from Dart streams.
-   **FutureBeacon**: Initialize beacons from futures.
-   **DerivedBeacon**: Compute values reactively based on other beacons.
-   **DerivedFutureBeacon**: Asynchronously compute values with state tracking.
-   **ListBeacon**: Manage lists reactively.
-   **createEffect**: React to changes in beacon values.
-   **doBatchUpdate**: Batch multiple updates into a single notification.

## Installation

Include `beacon` in your `pubspec.yaml` dependencies:

```yaml
dependencies:
    state_beacon: ^latest_version
    # or
    flutter_state_beacon: ^latest_version
```

## Usage

To use Beacon in your Dart project, first import the package:

```dart
import 'package:state_beacon/state_beacon.dart';
// or
import 'package:flutter_state_beacon/flutter_state_beacon.dart';
```

Then, you can create and use different types of beacons as needed:

### Creating a Writable Beacon

```dart
var counter = Beacon.writable(0);
```

### Executing code when a beacon value changes

```dart
Beacon.createEffect(() {
  print("Counter value is ${counter.value}");
});

// prints "Counter value is 1"
counter.value = 1;

// prints "Counter value is 50"
counter.value = 50;
```

### Using it in a widget

```dart
// this widget will rebuild whenever the counter changes
class Counter extends StatelessWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context) {
    return Text("Counter value is ${counter.value}");
  }
}
```

### More Examples

Pure Dart examples can be found [here](https://github.com/jinyus/dart_beacon/blob/master/state_beacon/example/state_beacon_example.dart)<br>
Flutter examples can be found [here](https://github.com/jinyus/dart_beacon/blob/master/flutter_state_beacon/example/lib/main.dart)

### Inspiration

[Preact Signals for dart](https://github.com/rodydavis/signals.dart) by Rody Davis  
[SolidJS](https://www.solidjs.com/) by Ryan Carniato.
