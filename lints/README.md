<p align="center">
  <img width="200" src="https://github.com/jinyus/dart_beacon/blob/main/assets/logo.png?raw=true">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-purple"> 
  <a href="https://app.codecov.io/github/jinyus/dart_beacon"><img src="https://img.shields.io/codecov/c/github/jinyus/dart_beacon"></a>
  <a href="https://pub.dev/packages/state_beacon"><img src="https://img.shields.io/pub/points/state_beacon?color=blue"></a>
</p>

## Overview

This is the liniting package for [state_beacon](https://pub.dev/packages/state_beacon). It provides a set of lints rules to help you write better code and avoid some of its [pitfalls](https://pub.dev/packages/state_beacon#pitfalls).

## Installation

```bash
dart pub add custom_lint
dart pub add state_beacon_lint

# or add these lines to your pubspec.yaml
dev_dependencies:
  custom_lint:
  state_beacon_lint:
```

Enable the `custom_lint` plugin in your `analysis_options.yaml` file.
Create the file if it doesn't exist and add the following:

```yaml
analyzer:
    plugins:
        - custom_lint
```

## Pitfalls of state_beacon

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
