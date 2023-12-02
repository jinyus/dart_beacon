<p align="center">
  <img width="200" src="https://github.com/jinyus/dart_beacon/blob/main/assets/logo.png?raw=true">
</p>

## Overview

A Beacon is a reactive primitive. This means that it provides facilities for executing any code when a it's value is modified.

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

## Usage

```dart
final name = Beacon.writable("Bob");
final age = Beacon.writable(20);
final college = Beacon.writable("MIT");

Beacon.createEffect(() {
  var msg = '${name.value} is ${age.value} years old';

  if (age.value > 21) {
      msg += ' and can go to ${college.value}';
  }
  print(msg);
});

name.value = "Alice"; // prints "Alice is 20 years old"
age.value = 21; // prints "Alice is 21 years old"
college.value = "Stanford"; // prints "Alice is 21 years old"
age.value = 22; // prints "Alice is 22 years old and can go to Stanford"
college.value = "Harvard"; // prints "Alice is 22 years old and can go to Harvard"
```
